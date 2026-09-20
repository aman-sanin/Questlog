import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../app/providers/keeper_provider.dart';
import '../../app/services/haptic_service.dart';
import '../../app/services/sound_service.dart';
import '../../domain/keeper/classifier.dart';
import '../../domain/keeper/expressions.dart';
import '../../domain/keeper/growth.dart';
import '../../domain/keeper/tunables.dart';
import '../../domain/model/models.dart';
import '../theme/tokens.dart';

/// A rising, fading `z` (dormant, Profile size only).
@immutable
class KeeperZmote {
  final Offset base;
  final double rise; // 0..1 along its 6dp rise
  final double alpha;
  const KeeperZmote({
    required this.base,
    required this.rise,
    required this.alpha,
  });
}

/// Motion input for one painted frame. The painter is a pure function of this
/// frozen state, so goldens and the glance test are deterministic (§1.9, §13).
@immutable
class KeeperMotion {
  final double phase;
  final double bobDy;
  final double breathY;
  final Offset gaze;
  final double blink; // 1 = open … 0.08 = shut
  final double eyeWide;
  final double pingProgress; // -1 = none, else 0..1
  final double gildProgress; // -1 = none, else 0..1
  final bool celebrate; // perfect-day D-hold window (§4)
  final double mouthPop; // 0..1 chirp mouth-pop (§4/§13)
  final double wiggleDeg; // 0 = idle, else pet wiggle amplitude (§7)
  final double recoil; // 0..1 boop recoil progress (§7)
  final double dizzy; // 0..1 tickle wobble progress (§7)
  final KeeperExpression expression; // the pose-reactive expression (§7)
  final List<KeeperZmote> zmotes;

  const KeeperMotion({
    required this.phase,
    required this.bobDy,
    required this.breathY,
    required this.gaze,
    required this.blink,
    required this.eyeWide,
    required this.pingProgress,
    required this.gildProgress,
    required this.celebrate,
    required this.mouthPop,
    required this.wiggleDeg,
    this.recoil = 0,
    this.dizzy = 0,
    this.expression = KeeperExpression.happy,
    required this.zmotes,
  });

  /// The frozen baseline: mid-bob, eyes open, no light active.
  static const KeeperMotion staticMotion = KeeperMotion(
    phase: 0.25,
    bobDy: 0,
    breathY: 1.0,
    gaze: Offset.zero,
    blink: 1.0,
    eyeWide: 1.0,
    pingProgress: -1,
    gildProgress: -1,
    celebrate: false,
    mouthPop: 0,
    wiggleDeg: 0,
    zmotes: [],
  );
}

/// The Keeper — a 12u-grid face that watches the day (keeper.md §2).
///
/// The state owns the eye channels (gaze, glance, blink, dilation, lids) and
/// the light menu (ring ping, gild flash, sparkle, z's); [KeeperMotion] is
/// computed each frame and the painter renders exactly what it is handed.
///
/// Pre-calling faces are 20% silhouettes (no glyph), but the mood still shows:
/// closed lines only while actually asleep, so even an unsummoned Keeper opens
/// its eyes once a single quest is completed today (§8 + acceptance gate 8).
class KeeperWidget extends StatefulWidget {
  final KeeperMood mood;
  final bool anticipation;
  final KeeperStage stage;
  final CallingDomain? calling;
  final double size;
  final KeeperEventBus? bus;
  final VoidCallback? onLongPress;
  final ValueChanged<KeeperExpression>? onExpressionChanged;

  const KeeperWidget({
    super.key,
    required this.mood,
    this.anticipation = false,
    this.stage = KeeperStage.summoned,
    this.calling,
    this.bus,
    this.onLongPress,
    this.onExpressionChanged,
    this.size = 84,
  });

  /// A summoned witness reveals its class glyph; otherwise a 20% silhouette.
  bool get summoned => calling != null;

  @override
  State<KeeperWidget> createState() => _KeeperWidgetState();
}

class _KeeperWidgetState extends State<KeeperWidget>
    with TickerProviderStateMixin {
  static final math.Random _rand = math.Random(0xBEEF);

  late final AnimationController _clock = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 4000),
  )..addListener(() => setState(() {}));

  // Blink: a full open→shut→open gesture over one curve.
  late final AnimationController _blink = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 240),
  );
  late final AnimationController _gaze = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: KeeperTunables.glanceTravelMs),
  );
  late final AnimationController _ping = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: KeeperTunables.pingMs),
  );
  late final AnimationController _gild = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: KeeperTunables.gildFlashMs),
  );
  late final AnimationController _wake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );

  // Poses (§4/§7).
  late final AnimationController _mouthPop = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: KeeperTunables.mouthPopMs),
  );
  late final AnimationController _wiggle = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: KeeperTunables.petWiggleMs),
  );
  late final AnimationController _recoil = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: KeeperTunables.boopMs),
  );
  late final AnimationController _dizzy = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: KeeperTunables.tickleMs),
  );
  late final AnimationController _surpriseWide = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: KeeperTunables.surpriseWideMs),
  );

  bool? _reducedMotion;
  Timer? _blinkTimer;
  Timer? _gazeTimer;
  Timer? _glanceReturnTimer;
  Timer? _gildDwellTimer;
  bool _celebrating = false;

  Offset _gazeStart = Offset.zero;
  Offset _gazeTarget = Offset.zero;

  int _busSeq = -1;

  // Affect registry (§7): poses held for a bounded window by [_holdPose].
  final Set<KeeperPose> _poses = {};
  Timer? _poseClearTimer;

  // Affection (§7): rises with strokes, decays gently on a 1s tick.
  double _affection = 0;
  Timer? _affectionDecayTimer;
  Timer? _strokePurrTimer;

  // Pointer/gaze (§7): target from hover/pan, eased through a spring.
  bool _pointerDown = false;
  bool _tapMoved = false;
  bool _gazeActive = false;
Offset _downPos = Offset.zero;
  Offset _gazePx = Offset.zero; // current smoothed gaze offset (px)
  Offset _gazeTargetPx = Offset.zero;
  final Stopwatch _lastMoveAt = Stopwatch()..start();
  Timer? _skepticalHoverTimer;

  // Tickle & boop burst counters (§7).
  final List<DateTime> _tapTimes = [];
  DateTime _tickleWindowStart = DateTime.now();
  int _tickleBursts = 0;
  DateTime _boopWindowStart = DateTime.now();
  int _boopStreak = 0;
  Timer? _longPressTimer;

  @override
  void initState() {
    super.initState();
    widget.bus?.addListener(_onEvent);
    _affectionDecayTimer = Timer.periodic(
      const Duration(
        milliseconds: KeeperTunables.affectionDecayTickMs,
      ),
      (_) {
        if (!mounted) return;
        final decay = KeeperTunables.petAffectionDecayPerSec *
            (KeeperTunables.affectionDecayTickMs / 1000);
        _affection = math.max(0, _affection - decay);
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final rm = MediaQuery.disableAnimationsOf(context);
    if (rm == _reducedMotion) return;
    _reducedMotion = rm;
    if (rm) {
      _pauseAll();
    } else {
      _clock.repeat();
      _wake.forward(from: 0);
      _scheduleNextBlink();
      _scheduleNextGaze();
    }
  }

  @override
  void didUpdateWidget(covariant KeeperWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bus != widget.bus) {
      oldWidget.bus?.removeListener(_onEvent);
      widget.bus?.addListener(_onEvent);
      _busSeq = -1;
    }
  }

  @override
  void dispose() {
    widget.bus?.removeListener(_onEvent);
    _blinkTimer?.cancel();
    _gazeTimer?.cancel();
    _glanceReturnTimer?.cancel();
    _gildDwellTimer?.cancel();
    _poseClearTimer?.cancel();
    _affectionDecayTimer?.cancel();
    _skepticalHoverTimer?.cancel();
    _strokePurrTimer?.cancel();
    _longPressTimer?.cancel();
    _clock.dispose();
    _blink.dispose();
    _gaze.dispose();
    _ping.dispose();
    _gild.dispose();
    _wake.dispose();
    _mouthPop.dispose();
    _wiggle.dispose();
    _recoil.dispose();
    _dizzy.dispose();
    _surpriseWide.dispose();
    super.dispose();
  }

  void _pauseAll() {
    _clock.stop();
    _blink.stop();
    _gaze.stop();
    _ping.stop();
    _gild.stop();
    _wake.stop();
    _mouthPop.stop();
    _wiggle.stop();
    _recoil.stop();
    _dizzy.stop();
    _surpriseWide.stop();
    _blinkTimer?.cancel();
    _gazeTimer?.cancel();
    _glanceReturnTimer?.cancel();
    _gildDwellTimer?.cancel();
    _gildDwellTimer = null;
    _celebrating = false;
  }

  // ── Event bus (keeper.md §5 plumbing) ─────────────────────────────────

  void _onEvent() {
    final ev = widget.bus?.last;
    if (ev == null || ev.seq <= _busSeq) return;
    _busSeq = ev.seq;

    // A pet is never a motion decision: haptics + purr fire even under
    // reduced motion — only the wiggle/glance are motion (§7, §8).
    if (ev.kind == KeeperEventKind.pet) {
      _stroke(_reducedMotion ?? true, announce: true);
      return;
    }

    if (_reducedMotion ?? true) return;

    switch (ev.kind) {
      case KeeperEventKind.complete:
        _onComplete(ev.cadence, ev.at);
      case KeeperEventKind.perfectDay:
        _onPerfectDay();
      case KeeperEventKind.pet:
        break; // handled above
    }
  }

  void _onComplete(Cadence? cadence, Offset? at) {
    final target = _clampedGlance(at);
    if (target != Offset.zero) _glanceTo(target);
    switch (cadence) {
      case Cadence.daily:
        _mouthPop.forward(from: 0); // mouth-sync hook (§4/§13)
        SoundService.playChirp();
      case Cadence.weekly:
      case Cadence.monthly:
      case Cadence.yearly:
      case Cadence.single:
        _ping.forward(from: 0);
        _holdPose(KeeperPose.shocked, KeeperTunables.shockedPoseMs);
        if (cadence == Cadence.weekly) SoundService.playChirp();
      case null:
        // A null cadence is the counter pull-back — the log records the
        // decrement, and the Keeper squints at it (§7).
        _holdPose(KeeperPose.skeptical, KeeperTunables.skepticalPoseMs);
        break;
    }
  }

  void _onPerfectDay() {
    _ping.forward(from: 0);
    _gild.forward(from: 0);
    setState(() => _celebrating = true);
    _holdPose(KeeperPose.ecstatic, KeeperTunables.gildHoldMs + 1000);
    _gildDwellTimer?.cancel();
    _gildDwellTimer = Timer(
      Duration(milliseconds: KeeperTunables.gildHoldMs),
      () {
        if (!mounted || (_reducedMotion ?? true)) return;
        setState(() => _celebrating = false);
      },
    );
    SoundService.playTrill();
  }

  /// Direction-only glance: point toward the event, clamped to the ±0.8u /
  /// ±0.6u window (§2).
  Offset _clampedGlance(Offset? at) {
    if (at == null || at.dx == 0 && at.dy == 0) return Offset.zero;
    final mag = math.sqrt(at.dx * at.dx + at.dy * at.dy);
    final u = widget.size / 12;
    final ux = at.dx / mag, uy = at.dy / mag;
    return Offset(
      ux * KeeperTunables.glanceClampU * u,
      uy * KeeperTunables.glanceClampVDU * u,
    );
  }

  void _glanceTo(Offset target) {
    _gazeStart = _currentGaze;
    _gazeTarget = target;
    _gaze.forward(from: 0);
    _glanceReturnTimer?.cancel();
    _glanceReturnTimer = Timer(
      Duration(
        milliseconds:
            KeeperTunables.glanceTravelMs + KeeperTunables.glanceHoldMs,
      ),
      () {
        if (!mounted || (_reducedMotion ?? true)) return;
        _gazeStart = _currentGaze;
        _gazeTarget = Offset.zero;
        _gaze.forward(from: 0);
        Timer(const Duration(milliseconds: 200), () {
          if (mounted) _doBlink();
        });
      },
    );
  }

  Offset get _currentGaze =>
      Offset.lerp(_gazeStart, _gazeTarget, _gaze.value) ?? Offset.zero;

  void _doBlink() {
    if (widget.mood == KeeperMood.dormant) return;
    _blink.forward(from: 0);
  }

  /// Idle gaze amplitude in px for the current mood: attentive watches
  /// furthest, content keeps a soft drift, resting barely moves, and a
  /// sleeping face doesn't wander at all (§5).
  double get _gazeAmplitude {
    final amp = KeeperTunables.gazeAmpU * widget.size / 12;
    return switch (widget.mood) {
      KeeperMood.attentive =>
        widget.anticipation
            ? amp * KeeperTunables.gazeAmpAnticipationScale
            : amp,
      KeeperMood.content => amp * KeeperTunables.gazeAmpContentScale,
      KeeperMood.resting => amp * KeeperTunables.gazeAmpRestingScale,
      KeeperMood.quiescent => amp * KeeperTunables.gazeAmpQuiescentScale,
      KeeperMood.dormant => 0,
    };
  }

  void _scheduleNextBlink() {
    _blinkTimer?.cancel();
    final waitMs =
        _rand.nextInt(KeeperTunables.blinkMaxMs - KeeperTunables.blinkMinMs) +
        KeeperTunables.blinkMinMs;
    _blinkTimer = Timer(Duration(milliseconds: waitMs), () {
      if (!mounted || (_reducedMotion ?? true)) return;
      // A sleeping face doesn't blink — eyes-only becomes stillness.
      if (widget.mood == KeeperMood.dormant) {
        _scheduleNextBlink();
        return;
      }
      _doBlink();
      if (_rand.nextDouble() < KeeperTunables.doubleBlinkP) {
        Timer(const Duration(milliseconds: 400), () {
          if (mounted && !(_reducedMotion ?? true)) _doBlink();
        });
      }
      _scheduleNextBlink();
    });
  }

  /// Idle eye movement: a saccade — dart, hold, return, blink — rather than a
  /// set-and-hold drift, so the watching reads as alive (§2/§5).
  void _scheduleNextGaze() {
    _gazeTimer?.cancel();
    final waitMs =
        _rand.nextInt(KeeperTunables.gazeMaxMs - KeeperTunables.gazeMinMs) +
        KeeperTunables.gazeMinMs;
    _gazeTimer = Timer(Duration(milliseconds: waitMs), () {
      if (!mounted || (_reducedMotion ?? true)) return;
      final amp = _gazeAmplitude;
      if (widget.mood == KeeperMood.dormant || amp <= 0) {
        _scheduleNextGaze();
        return;
      }
      final target = Offset(
        (_rand.nextDouble() * 2 - 1) * amp,
        (_rand.nextDouble() * 2 - 1) * amp * 0.6,
      );
      _glanceTo(target); // travel → hold → return (blinks on the way back)
      _scheduleNextGaze();
    });
  }

  /// Hold a transient affect pose for a bounded window (§7), then release.
  void _holdPose(KeeperPose pose, int ms) {
    _poseClearTimer?.cancel();
    _poses.add(pose);
    _poseClearTimer = Timer(Duration(milliseconds: ms), () {
      if (!mounted) return;
      _poses.remove(pose);
    });
  }

  /// Stroke: affection rises, purr + haptic fire regardless of reduced
  /// motion; the wiggle/glance are motion and stay gated (§7).
  void _stroke(bool rm, {required bool announce}) {
    _affection = math.min(
      1.0,
      _affection + KeeperTunables.petAffectionPerStroke,
    );
    if (announce) {
      HapticService.light();
      if (_strokePurrTimer == null || !_strokePurrTimer!.isActive) {
        _strokePurrTimer = Timer(
          Duration(milliseconds: KeeperTunables.strokePurrMinMs),
          () {},
        );
        SoundService.playPurr();
      }
    }
    if (rm) return;
    _wiggle.forward(from: 0);
    if (_affection >= KeeperTunables.inLoveAffection) {
      _holdPose(KeeperPose.inLove, KeeperTunables.inLovePoseMs);
    }
    _glanceTo(Offset(0, KeeperTunables.glanceClampVDU * widget.size / 12));
  }

  /// Boop: recoil + surprise-widen + chirp; rapid taps turn into a tickle
  /// (giggle, dizzy spin, cheeky) and unbroken abuse drifts into the affect
  /// range — sad after too many boops, grumpy after too many tickles. All of
  /// it is response to interaction, never to the day (§7).
  void _boop(bool rm) {
    final withinBurst =
        DateTime.now().difference(_boopWindowStart).inMilliseconds <
            KeeperTunables.boopWindowMs;
    _boopStreak = withinBurst ? _boopStreak + 1 : 1;
    _boopWindowStart = DateTime.now();

    HapticService.light();

    if (_countTapBurst()) {
      SoundService.playGiggle();
      _dizzy.forward(from: 0);
      final tickleWindow =
          DateTime.now().difference(_tickleWindowStart).inMilliseconds <
              KeeperTunables.grumpyWindowMs;
      _tickleBursts = tickleWindow ? _tickleBursts + 1 : 1;
      _tickleWindowStart = DateTime.now();
      _holdPose(KeeperPose.cheeky, KeeperTunables.cheekyPoseMs);
      if (_tickleBursts >= KeeperTunables.grumpyTickles) {
        _holdPose(KeeperPose.grumpy, KeeperTunables.grumpyPoseMs);
        _tickleBursts = 0;
      }
    } else {
      SoundService.playBoop();
      _recoil.forward(from: 0);
      _surpriseWide.forward(from: 0);
      if (_boopStreak >= KeeperTunables.boopSadCount) {
        SoundService.playSigh();
        _holdPose(KeeperPose.sad, KeeperTunables.sadPoseMs);
        _boopStreak = 0;
      }
    }
    if (rm) return;
    _blink.forward(from: 0);
  }

  /// Taps inside the tickle window accumulate into a burst; a full burst
  /// clears and reports a tickle (§7).
  bool _countTapBurst() {
    final now = DateTime.now();
    _tapTimes.add(now);
    while (_tapTimes.isNotEmpty &&
        now.difference(_tapTimes.first).inMilliseconds >
            KeeperTunables.tickleWindowMs) {
      _tapTimes.removeAt(0);
    }
    if (_tapTimes.length >= KeeperTunables.ticklesRequired) {
      _tapTimes.clear();
      return true;
    }
    return false;
  }

  // ── Pointer: gaze, stroke, tap/long-press (§7) ─────────────────────────

  void _onPointerDown(PointerDownEvent event) {
    _pointerDown = true;
    _tapMoved = false;
    _downPos = event.localPosition;
    _setGazeTarget(event.localPosition);
    _skepticalHoverTimer?.cancel();
    _skepticalHoverTimer = Timer(
      Duration(milliseconds: KeeperTunables.skepticalHoverMs),
      () {
        if (!mounted || !_pointerDown) return;
        _holdPose(KeeperPose.skeptical, KeeperTunables.skepticalPoseMs);
      },
    );
    if (widget.onLongPress != null) {
      _longPressTimer?.cancel();
      _longPressTimer = Timer(
        const Duration(milliseconds: 500),
        () {
          if (!mounted || !_pointerDown || _tapMoved) return;
          widget.onLongPress?.call();
        },
      );
    }
  }

  void _onPointerMove(PointerMoveEvent event) {
    _setGazeTarget(event.localPosition);
    final dist =
        _pointerDown ? (event.localPosition - _downPos).distance : 0.0;
    if (_pointerDown && dist > kTouchSlop) {
      if (!_tapMoved) {
        _tapMoved = true;
        _longPressTimer?.cancel();
      }
      _lastMoveAt.reset();
      _stroke(_reducedMotion ?? true, announce: true);
    }
  }

  /// Desktop hover is itself a stroke: moving over the face purrs, and the
  /// gaze follows the pointer (§7). Hovers arrive as [PointerHoverEvent].
  void _onPointerHover(PointerHoverEvent event) {
    _setGazeTarget(event.localPosition);
    if (event.kind == PointerDeviceKind.mouse &&
        _lastMoveAt.elapsedMilliseconds > KeeperTunables.strokePurrMinMs) {
      _lastMoveAt.reset();
      _stroke(_reducedMotion ?? true, announce: true);
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    _skepticalHoverTimer?.cancel();

    if (_pointerDown && !_tapMoved) {
      _boop(_reducedMotion ?? true);
    }
    _pointerDown = false;
    if (event.kind != PointerDeviceKind.mouse) {
      _gazeActive = false;
      _gazeTargetPx = Offset.zero;
    }
  }

  void _onPointerEnter(PointerEnterEvent event) {
    _gazeActive = true;
    _setGazeTarget(event.localPosition);
  }

  void _onPointerExit(PointerExitEvent event) {
    _gazeActive = false;
    _gazeTargetPx = Offset.zero;
    _skepticalHoverTimer?.cancel();
  }

  void _onPointerCancel(PointerCancelEvent event) {
    _skepticalHoverTimer?.cancel();

    _pointerDown = false;
    _gazeActive = false;
    _gazeTargetPx = Offset.zero;
  }

  /// Map a local pointer position to a clamped gaze offset; the whole eye
  /// follows as far as the eye-socket clamp allows (§7).
  void _setGazeTarget(Offset local) {
    if (!mounted || (_reducedMotion ?? true)) return;
    _gazeActive = true;
    final u = widget.size / 12;
    final follow = KeeperTunables.gazeFollowU * u;
    final center = Offset(widget.size / 2, widget.size / 2);
    final toEye = follow / (2.2 * u); // eye sits ±2.2u from center
    _gazeTargetPx = Offset(
      ((local.dx - center.dx) * toEye).clamp(-follow, follow),
      ((local.dy - center.dy) * toEye).clamp(-0.6 * u, 0.6 * u),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final rm = _reducedMotion ?? true;
    final size = widget.size;
    final motion = _motionFor(rm);
    widget.onExpressionChanged?.call(motion.expression);

    return Transform.translate(
      offset: Offset(0, motion.bobDy),
      child: Transform.scale(
        scaleY: motion.breathY,
        child: SizedBox(
          width: size,
          height: size,
          child: MouseRegion(
            onEnter: _onPointerEnter,
            onExit: _onPointerExit,
            child: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: _onPointerDown,
              onPointerMove: _onPointerMove,
              onPointerHover: _onPointerHover,
              onPointerUp: _onPointerUp,
              onPointerCancel: _onPointerCancel,
              child: CustomPaint(
                painter: KeeperPainter(
                  state: KeeperPaintState(
                    mood: widget.mood,
                    anticipation: widget.anticipation,
                    stage: widget.stage,
                    calling: widget.calling,
                    summoned: widget.summoned,
                    size: size,
                  ),
                  motion: motion,
                  tokens: context.tokens,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  KeeperMotion _motionFor(bool rm) {
    if (rm) return KeeperMotion.staticMotion;

    final phase = _clock.value;
    // Single shared 4s phase clock; per-construct phase offsets (§2, §6).
    const span = 4000;
    var bob =
        -KeeperTunables.bobAmpDp *
        math.sin(2 * math.pi * phase * (span / KeeperTunables.bobMs));
    final pulseMs = widget.anticipation
        ? KeeperTunables.pulseAnticipationMs
        : KeeperTunables.pulseMs;
    var breath =
        1 +
        (KeeperTunables.pulseScale - 1) *
            (0.5 +
                0.5 * math.sin(2 * math.pi * phase * (span / pulseMs) + 0.6));

    // Boop recoil: a dip-and-return on both axes (§7).
    final recoil = _recoil.isAnimating ? _recoil.value : 0.0;
    if (recoil > 0) {
      final p = math.sin(math.pi * recoil);
      bob += KeeperTunables.boopSinkPx * p;
      breath *= 1 - (1 - KeeperTunables.boopSquash) * p;
    }
    final dizzy = _dizzy.isAnimating ? _dizzy.value : 0.0;

    // Blink curve: open→shut→open across the controller.
    final blink = 1.0 - math.sin(math.pi * _blink.value).abs() * 0.92;

    // Pointer gaze: ease toward the hover/pan target, then clamp with the
    // glance channel inside the socket (§7).
    if (_gazeActive) {
      _gazePx =
          Offset.lerp(_gazePx, _gazeTargetPx, KeeperTunables.gazeSpringK) ??
          _gazeTargetPx;
    } else {
      _gazePx =
          Offset.lerp(_gazePx, Offset.zero, KeeperTunables.gazeSpringK) ??
          Offset.zero;
    }
    final u = widget.size / 12;
    final follow = _currentGaze + _gazePx;
    final gaze = Offset(
      follow.dx.clamp(-KeeperTunables.glanceClampU * u, KeeperTunables.glanceClampU * u),
      follow.dy.clamp(-KeeperTunables.glanceClampVDU * u, KeeperTunables.glanceClampVDU * u),
    );

    return KeeperMotion(
      phase: phase,
      bobDy: bob,
      breathY: breath,
      gaze: gaze,
      blink: blink,
      eyeWide:
          (widget.anticipation ? KeeperTunables.wide : 1.0) *
          (1 + 0.3 * _surpriseWide.value),
      pingProgress: _ping.isAnimating ? _ping.value : -1,
      gildProgress: _gild.isAnimating ? _gild.value : -1,
      celebrate: _celebrating,
      mouthPop: _mouthPop.isAnimating ? _mouthPop.value : 0,
      wiggleDeg: _wiggle.isAnimating ? _wiggle.value * 2 * 3 - 3 : 0,
      recoil: recoil,
      dizzy: dizzy,
      expression: _expressionFor(false),
      zmotes: _zmotesFor(phase),
    );
  }

  /// The expression for this frame: poses beat the mood baseline, and under
  /// reduced motion the portrait stays still (§7).
  KeeperExpression _expressionFor(bool rm) {
    if (rm) return KeeperExpression.happy;
    return resolveKeeperExpression(poses: _poses, mood: widget.mood);
  }

  List<KeeperZmote> _zmotesFor(double phase) {
    if (widget.size < KeeperTunables.zMoteMinSize) return const [];
    return [
      for (var i = 0; i < 2; i++)
        KeeperZmote(
          base: Offset(
            widget.size / 2 + (i % 2 == 0 ? -0.18 : 0.18) * widget.size,
            widget.size / 2 - 0.2 * widget.size,
          ),
          rise: (phase + 0.6 * i) % 1.0,
          alpha: (1 - ((phase + 0.6 * i) % 1.0)) * 0.6,
        ),
    ];
  }
}

/// Frozen visual state handed to the painter (§5).
@immutable
class KeeperPaintState {
  final KeeperMood mood;
  final bool anticipation;
  final KeeperStage stage;
  final CallingDomain? calling;
  final bool summoned;
  final double size;
  const KeeperPaintState({
    required this.mood,
    required this.anticipation,
    required this.stage,
    required this.calling,
    required this.summoned,
    required this.size,
  });
}

/// The painter — a pure function of state + motion; no wall clock (§1.9).
/// Renders the Kiko design face from assets/msc/code.html — the 64px capsule
/// eyes and 64x40 mouth block — scaled to the box, white-on-OLED (§2/§7).
class KeeperPainter extends CustomPainter {
  final KeeperPaintState state;
  final KeeperMotion motion;
  final AppTokens tokens;

  KeeperPainter({
    required this.state,
    required this.motion,
    required this.tokens,
  });

  double get _s => state.size;
  double get _u => _s / 12;
  double get cx => _s / 2;
  double get cy => _s / 2;

  bool get _gilded =>
      state.stage == KeeperStage.gilded || motion.gildProgress >= 0;
  bool get _celebrating => motion.celebrate || motion.gildProgress >= 0;
  bool get _petting => motion.wiggleDeg != 0;
  bool get _ember => _gilded || _celebrating;
  bool get _gildedFace => _ember || _petting;

  Color get _fore => _ember ? tokens.hero : tokens.textPrimary;
  double get _value =>
      state.summoned ? (_ember ? 0.9 : moodAlpha(state.mood)) : 0.20;

  static double moodAlpha(KeeperMood m) => switch (m) {
    KeeperMood.quiescent => 0.35,
    KeeperMood.dormant => 0.35,
    KeeperMood.attentive => 0.55,
    KeeperMood.content => 0.85,
    KeeperMood.resting => 0.70,
  };

  double get _strokeDp => math.max(1.0, 2 * _s / 96);

  // ── Kiko design geometry (assets/msc/code.html) ────────────────────────
  // The face block is one 64px eye svg + a gap + another eye svg, then 16px
  // + the 64x40 mouth svg. `_k` maps design units -> px so the widest pose
  // (sad, gap-20) fills the box; the gap shrinks per expression just like
  // the design's gap-16 / gap-14 / gap-20 eye sliders.
  double get _k => _s / (128 + _eyeGap);

  /// Deliberate user-approved nudge: eyes sit 8% closer than the design
  /// gap (keeper.md §7). Does not touch `_k`, so nothing else resizes.
  static const double _eyeSpread = 0.92;

  double get _eyeGap => switch (motion.expression) {
        KeeperExpression.skeptical ||
        KeeperExpression.shocked ||
        KeeperExpression.grumpy =>
          56, // gap-14
        KeeperExpression.sad => 80, // gap-20
        _ => 64, // gap-16
      };

  /// Vertical centre of the eye row (blockTop + 32k).
  double get _eyeRow => cy - 28 * _k;

  /// Vertical centre of the mouth block (blockTop + 100k).
  double get _mouthRow => cy + 40 * _k;

  /// Eye pivot for a side (dir: -1 = left, +1 = right) in canvas px.
  Offset _eyeC(double dir) => Offset(
        cx + dir * (64 + _eyeGap) * _k / 2 * _eyeSpread,
        _eyeRow + _wobble,
      );

  /// Blink squash: a full open->0.08->open scale, matching the design's
  /// `scaleY(0.08)` double-blink (blink: 1 = open … 0.08 = shut).
  double get _blinkY => math.max(0.08, motion.blink);

  /// Draw `body` in the design's 64x64 eye space, centred on [ec], at the
  /// design scale (stroke widths are design units -> px via the canvas CTM).
  void _drawInEye(Canvas canvas, Offset ec, void Function(Canvas) draw,
      {double scale = 1.0}) {
    canvas.save();
    canvas.translate(ec.dx, ec.dy);
    canvas.scale(_k * scale);
    canvas.translate(-32, -32);
    draw(canvas);
    canvas.restore();
  }

  /// Draw `body` in the design's 64x40 mouth space, centred on [mc].
  void _drawInMouth(Canvas canvas, Offset mc, void Function(Canvas) draw) {
    canvas.save();
    canvas.translate(mc.dx - 32 * _k, mc.dy - 20 * _k);
    canvas.scale(_k);
    draw(canvas);
    canvas.restore();
  }

  Paint get _ink => Paint()
    ..color = _fore.withValues(alpha: _value)
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  double get _wobble {
    var wob =
        _petting ? 0.4 * _u * math.sin(motion.wiggleDeg / 3 * math.pi) : 0.0;
    if (motion.dizzy > 0) {
      wob += KeeperTunables.tickleWobbleAmpU *
          _u *
          math.sin(motion.dizzy * math.pi * 4);
    }
    return wob;
  }

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final s = state.size;
    canvas.clipRect(Offset.zero & Size(s, s)); // never exceed the box (§1.9)
    final cx = s / 2, cy = s / 2;

    final strokePaint = Paint()
      ..color = _fore.withValues(alpha: _value)
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeDp
      ..strokeCap = StrokeCap.round;
    final fillPaint = Paint()..color = _fore.withValues(alpha: _value);

    // ── Gild halo — ember ring expanding behind the face (§6) ────────────
    if (motion.gildProgress >= 0) {
      final p = motion.gildProgress;
      canvas.drawCircle(
        Offset(cx, cy),
        4 * _u * (1 + 0.8 * (1 - p)),
        Paint()
          ..color = tokens.hero.withValues(alpha: 0.5 * (1 - p))
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(1.5, s / 20),
      );
    }

    // ── Class glyph — 2dp-stroke, floats above the eye row (§2/§8) ───────
    if (state.summoned && state.calling != null && s >= 40) {
      _paintGlyph(canvas, cx, cy, strokePaint);
    }

    // ── Eyes: the expression surface (§5) ────────────────────────────────
    _paintEyes(canvas, strokePaint, fillPaint);

    // ── Sparkle — corner diamonds, celebrating/gilded only (§4) ──────────
    if (_ember && state.summoned && s >= KeeperTunables.sparkleMinSize) {
      _paintSparkles(canvas, fillPaint);
    }

    // ── Mouth: the expression surface (§5) ───────────────────────────────
    _paintMouth(canvas, strokePaint, fillPaint);

    // ── Ring ping — hairline circle from the face center (§6) ───────────
    if (motion.pingProgress >= 0) {
      final p = motion.pingProgress;
      canvas.drawCircle(
        Offset(cx, cy),
        4 * _u,
        Paint()
          ..color = tokens.textSecondary.withValues(alpha: 0.25 * (1 - p))
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(1.0, s / 96),
      );
    }

    // ── Particles — z's while dormant, white hearts for the love pose
    // (the design floats hearts above a smitten face) (§6/§7).
    if ((state.mood == KeeperMood.dormant && state.summoned) ||
        motion.expression == KeeperExpression.inLove) {
      for (final z in motion.zmotes) {
        _drawZmote(canvas, z);
      }
    }
  }

  // ── Eyes ───────────────────────────────────────────────────────────────

  void _paintEyes(Canvas canvas, Paint stroke, Paint fill) {
    for (final dir in [-1.0, 1.0]) {
      final ec = _eyeC(dir) + motion.gaze;
      final gw = 28 * _k * motion.eyeWide;

      switch (motion.expression) {
        case KeeperExpression.ecstatic:
          // Held delight: filled dome + inner highlight (design ecstatic).
          _drawInEye(canvas, ec, (c) {
            c.drawPath(
              Path()
                ..moveTo(12, 30)
                ..cubicTo(18, 16, 44, 16, 52, 30)
                ..cubicTo(44, 22, 20, 22, 12, 30)
                ..close(),
              fill,
            );
            final hl = Offset(dir < 0 ? 16 : 48, 37);
            c.drawOval(
              Rect.fromCenter(center: hl, width: 16, height: 7),
              Paint()..color = _fore.withValues(alpha: _value * 0.4),
            );
          }, scale: motion.eyeWide);
          continue;
        case KeeperExpression.inLove:
          // Love: the design's white heart silhouette in each socket.
          _drawInEye(canvas, ec, (c) {
            c.drawPath(_kHeartPath(), fill);
          }, scale: motion.eyeWide);
          continue;
        case KeeperExpression.cheeky:
          // Cheeky: a closed wink crescent over the near eye (§7).
          if (dir < 0) {
            _drawInEye(canvas, ec, (c) {
              c.drawPath(
                Path()
                  ..moveTo(16, 32)
                  ..quadraticBezierTo(32, 20, 48, 32),
                _ink..strokeWidth = 6,
              );
            });
          } else {
            _drawCapsule(canvas, ec, fill);
          }
          continue;
        case KeeperExpression.skeptical:
          // Skeptical: slanted squint slits, one raised (§7).
          _drawInEye(canvas, ec, (c) {
            final cy2 = dir < 0 ? 30.0 : 36.0;
            final ang = (dir < 0 ? -6 : 4) * math.pi / 180;
            c.save();
            c.translate(32, cy2);
            c.rotate(ang);
            c.translate(-32, -cy2);
            c.drawRRect(
              RRect.fromRectAndRadius(
                Rect.fromLTWH(12, cy2 - 6, 40, 12),
                const Radius.circular(6),
              ),
              fill,
            );
            c.restore();
          });
          continue;
        case KeeperExpression.shocked:
          // Shocked: thin white ring hugging a solid white core (§7).
          _drawInEye(canvas, ec, (c) {
            final s = motion.eyeWide;
            c.drawCircle(
              const Offset(32, 32),
              24 * s,
              _ink..strokeWidth = 5,
            );
            c.drawCircle(const Offset(32, 32), 10 * s, fill);
          }, scale: motion.eyeWide);
          continue;
        case KeeperExpression.sad:
          // Sad: a drooping triangle, apex to the centre line (§7).
          _drawInEye(canvas, ec, (c) {
            final p = Path();
            if (dir < 0) {
              p
                ..moveTo(8, 34)
                ..lineTo(46, 18)
                ..lineTo(46, 46);
            } else {
              p
                ..moveTo(56, 34)
                ..lineTo(18, 18)
                ..lineTo(18, 46);
            }
            c.drawPath(p..close(), fill);
          });
          continue;
        case KeeperExpression.grumpy:
          // Grumpy: a gnarly storm-blob rolling toward the middle (§7).
          _drawInEye(canvas, ec, (c) {
            final p = Path();
            if (dir < 0) {
              p
                ..moveTo(12, 40)
                ..cubicTo(12, 24, 26, 12, 44, 22)
                ..lineTo(48, 38)
                ..cubicTo(42, 50, 16, 52, 12, 40);
            } else {
              p
                ..moveTo(52, 40)
                ..cubicTo(52, 24, 38, 12, 20, 22)
                ..lineTo(16, 38)
                ..cubicTo(22, 50, 48, 52, 52, 40);
            }
            c.drawPath(p..close(), fill);
          });
          continue;
        case KeeperExpression.sleepy:
          // Sleepy: droopy half-lid — arc over a translucent eye (§7).
          if (state.mood == KeeperMood.dormant) {
            _drawClosedLine(canvas, ec);
          } else {
            _drawInEye(canvas, ec, (c) {
              c.drawPath(
                Path()
                  ..moveTo(14, 32)
                  ..quadraticBezierTo(32, 18, 50, 32),
                _ink..strokeWidth = 5,
              );
              c.drawPath(
                Path()
                  ..moveTo(16, 32)
                  ..cubicTo(16, 38, 48, 38, 48, 32)
                  ..close(),
                Paint()..color = _fore.withValues(alpha: _value * 0.4),
              );
            });
          }
          continue;
        case KeeperExpression.happy:
          _drawBaseEye(canvas, ec, gw, fill);
          continue;
      }
    }
  }

  /// The design's capsule eye — a fully-rounded 28x44 pill (§7).
  void _drawCapsule(Canvas canvas, Offset ec, Paint fill) {
    final w = 28 * _k * motion.eyeWide;
    final h = 44 * _k * _blinkY;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: ec, width: w, height: h),
        Radius.circular(14 * _k),
      ),
      fill,
    );
  }

  /// The mood-modulated baseline eye: solid design capsules, a resting
  /// half-lid, a closed line while asleep. No pupils — the robo face (§7).
  void _drawBaseEye(Canvas canvas, Offset ec, double gw, Paint fill) {
    final closed = state.mood == KeeperMood.dormant;
    final halfLid = state.mood == KeeperMood.resting && state.summoned;

    if (closed) {
      _drawClosedLine(canvas, ec);
      return;
    }

    _drawCapsule(canvas, ec, fill);

    // Resting half-lid — the sticking eye, softly shut (§5).
    if (halfLid) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(
            ec.dx - gw / 2,
            ec.dy - 22 * _k,
            ec.dx + gw / 2,
            ec.dy - 22 * _k + 44 * _k * 0.45,
          ),
          Radius.circular(10 * _k),
        ),
        Paint()..color = tokens.bg,
      );
    }
  }

  /// A shut eye — the design's blink squash held as a thin closed line (§5).
  void _drawClosedLine(Canvas canvas, Offset ec) {
    canvas.drawRect(
      Rect.fromCenter(
        center: ec,
        width: 28 * _k * motion.eyeWide,
        height: 0.15 * _u,
      ),
      Paint()..color = _fore.withValues(alpha: _value),
    );
  }

  /// The design's heart silhouette (love eyes / love zmotes), in the 64 box.
  static Path _kHeartPath() => Path()
    ..moveTo(32, 46)
    ..cubicTo(32, 46, 16, 34, 16, 22)
    ..cubicTo(16, 16, 21, 12, 26, 12)
    ..cubicTo(29, 12, 31, 14, 32, 16)
    ..cubicTo(33, 14, 35, 12, 38, 12)
    ..cubicTo(43, 12, 48, 16, 48, 22)
    ..cubicTo(48, 34, 32, 46, 32, 46)
    ..close();

  // ── Mouth ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

  void _paintMouth(Canvas canvas, Paint stroke, Paint fill) {
    // Mouth-sync parallax: the design moves the mouth at half the eye travel.
    final my = _mouthRow + _wobble + motion.gaze.dy * 0.5;
    final mc = Offset(cx + motion.gaze.dx * 0.5, my);

    // Mouth-sync: the chirp pops a small open mouth for ~150ms (§4/§13).
    if (motion.mouthPop > 0) {
      _paintPop(canvas, mc, fill);
      return;
    }

    switch (motion.expression) {
      case KeeperExpression.ecstatic:
        // Design ecstatic: a wide open happy mouth (keeper.md §7).
        _drawInMouth(canvas, mc, (c) {
          c.drawPath(
            Path()
              ..moveTo(18, 10)
              ..cubicTo(18, 10, 14, 34, 32, 34)
              ..cubicTo(50, 34, 46, 10, 46, 10)
              ..close(),
            fill,
          );
        });
        return;
      case KeeperExpression.inLove:
        // Design love: a soft downward smile arc (§7).
        _drawInMouth(canvas, mc, (c) {
          c.drawPath(
            Path()
              ..moveTo(22, 18)
              ..cubicTo(26, 27, 38, 27, 42, 18),
            _ink..strokeWidth = 4,
          );
        });
        return;
      case KeeperExpression.cheeky:
        // Design cheeky: a smirking arc with a poking tongue (§7).
        _drawInMouth(canvas, mc, (c) {
          c.drawPath(
            Path()
              ..moveTo(20, 18)
              ..quadraticBezierTo(32, 24, 44, 16),
            _ink..strokeWidth = 4,
          );
          c.drawPath(
            Path()
              ..moveTo(28, 20)
              ..cubicTo(28, 20, 28, 32, 34, 32)
              ..cubicTo(40, 32, 40, 20, 40, 20)
              ..close(),
            fill,
          );
        });
        return;
      case KeeperExpression.skeptical:
        // Design skeptical: a flat squiggly dubius line (§7).
        _drawInMouth(canvas, mc, (c) {
          c.drawPath(
            Path()
              ..moveTo(22, 24)
              ..quadraticBezierTo(28, 20, 33, 25)
              ..quadraticBezierTo(38, 30, 44, 22),
            _ink..strokeWidth = 4.5,
          );
        });
        return;
      case KeeperExpression.shocked:
        // Design shocked: a big round O (§7).
        _drawInMouth(canvas, mc, (c) {
          c.drawCircle(
            const Offset(32, 22),
            12,
            _ink..strokeWidth = 4,
          );
        });
        return;
      case KeeperExpression.sad:
        // Design sad: a filled downturned crescent (§7).
        _drawInMouth(canvas, mc, (c) {
          c.drawPath(
            Path()
              ..moveTo(20, 26)
              ..quadraticBezierTo(32, 14, 44, 26)
              ..quadraticBezierTo(32, 20, 20, 26)
              ..close(),
            fill,
          );
        });
        return;
      case KeeperExpression.grumpy:
        // Design grumpy: a downward chevron, notched flat (§7).
        _drawInMouth(canvas, mc, (c) {
          c.drawPath(
            Path()
              ..moveTo(22, 28)
              ..lineTo(32, 16)
              ..lineTo(42, 28)
              ..lineTo(39, 30)
              ..lineTo(32, 21)
              ..lineTo(25, 30)
              ..close(),
            fill,
          );
        });
        return;
      case KeeperExpression.sleepy:
        if (state.mood == KeeperMood.dormant) {
          // Tiny dot — asleep (keeper.md §5).
          canvas.drawRect(
            Rect.fromCenter(
              center: mc,
              width: 0.5 * _u,
              height: 0.5 * _u,
            ),
            fill,
          );
        } else {
          // Design sleepy: a small dormant oval (§7).
          _drawInMouth(canvas, mc, (c) {
            c.drawOval(
              Rect.fromCenter(center: const Offset(32, 22), width: 9, height: 7),
              fill,
            );
          });
        }
        return;
      case KeeperExpression.happy:
        _paintHappyMouth(canvas, mc, stroke, fill);
        return;
    }
  }

  void _paintHappyMouth(Canvas canvas, Offset mc, Paint stroke, Paint fill) {
    if (state.mood == KeeperMood.quiescent) {
      // `〜` — three 1u segments, drifting (keeper.md §5).
      _paintWavy(canvas, mc, stroke);
      return;
    }
    if (state.mood == KeeperMood.dormant) {
      // Tiny dot — asleep (keeper.md §5).
      canvas.drawRect(
        Rect.fromCenter(center: mc, width: 0.5 * _u, height: 0.5 * _u),
        fill,
      );
      return;
    }
    if (_gildedFace) {
      // `D` — delighted (keeper.md §5).
      _paintD(canvas, mc, fill);
      return;
    }
    // Design happy / attentive default: the flat-topped open smile — the HTML
    // default in code.html (§7). A straight `—` was the old wake-neutral line.
    _drawInMouth(canvas, mc, (c) {
      c.drawPath(
        Path()
          ..moveTo(22, 14)
          ..cubicTo(22, 14, 24, 28, 32, 28)
          ..cubicTo(40, 28, 42, 14, 42, 14)
          ..close(),
        fill,
      );
    });
  }

  void _paintWavy(Canvas canvas, Offset mc, Paint stroke) {
    for (var i = 0; i < 3; i++) {
      final xc = mc.dx + (i - 1) * 1.0 * _u;
      final ys = mc.dy + (i - 1) * 0.5 * _u;
      canvas.drawLine(
        Offset(xc - 0.5 * _u, ys),
        Offset(xc + 0.5 * _u, ys),
        stroke,
      );
    }
  }

  void _paintPop(Canvas canvas, Offset mc, Paint fill) {
    final h = 1.0 * _u * motion.mouthPop;
    final w = 2.2 * _u;
    final topY = mc.dy - h;
    final p = Path()
      ..moveTo(mc.dx - w / 2, topY)
      ..lineTo(mc.dx + w / 2, topY)
      ..quadraticBezierTo(mc.dx, mc.dy, mc.dx - w / 2, topY)
      ..close();
    canvas.drawPath(p, fill);
  }

  void _paintD(Canvas canvas, Offset mc, Paint fill) {
    final w = 3.5 * _u;
    final h = 1.8 * _u;
    final topY = mc.dy - h;
    final p = Path()
      ..moveTo(mc.dx - w / 2, topY)
      ..lineTo(mc.dx + w / 2, topY)
      ..quadraticBezierTo(mc.dx, mc.dy, mc.dx - w / 2, topY)
      ..close();
    canvas.drawPath(p, fill);
  }

  // ── Glyph (§2/§8) ──────────────────────────────────────────────────────

  void _paintGlyph(Canvas canvas, double cx, double cy, Paint strokePaint) {
    // Raised a touch over the design bed (cy - 4.4u) per user request; the
    // halo ring (r*1.5) follows and loses ~1px of its top arc at adorned+.
    final gy = cy - 4.4 * _u;
    final r = 1.2 * _u;
    final ember = _ember || state.stage.index >= KeeperStage.trimmed.index;
    final stroke = Paint()
      ..color = (ember ? tokens.hero : tokens.textPrimary)
          .withValues(alpha: _value)
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeDp
      ..strokeCap = StrokeCap.round;

    final path = switch (state.calling!) {
      CallingDomain.sage => _star(Offset(cx, gy), r),
      CallingDomain.warrior => _chevron(Offset(cx, gy), r),
      CallingDomain.monk => _ring(Offset(cx, gy), r),
      CallingDomain.bard => _bars(Offset(cx, gy), r),
      CallingDomain.ranger => _peaks(Offset(cx, gy), r),
      CallingDomain.artificer => _hex(Offset(cx, gy), r),
    };
    canvas.drawPath(path, stroke);
    if (state.stage.index >= KeeperStage.adorned.index) {
      canvas.drawCircle(
        Offset(cx, gy),
        r * 1.5,
        Paint()
          ..color = stroke.color.withValues(alpha: 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(0.8, _s / 96),
      );
    }
  }

  static Path _star(Offset c, double r) {
    final p = Path();
    for (var i = 0; i < 8; i++) {
      final rad = i.isEven ? r : r * 0.45;
      final a = -math.pi / 2 + i * math.pi / 4;
      final pt = c + Offset(rad * math.cos(a), rad * math.sin(a));
      i == 0 ? p.moveTo(pt.dx, pt.dy) : p.lineTo(pt.dx, pt.dy);
    }
    p.close();
    return p;
  }

  static Path _chevron(Offset c, double r) => Path()
    ..moveTo(c.dx - r, c.dy - r * 0.5)
    ..lineTo(c.dx, c.dy + r * 0.5)
    ..lineTo(c.dx + r, c.dy - r * 0.5);

  static Path _ring(Offset c, double r) =>
      Path()..addArc(Rect.fromCircle(center: c, radius: r * 0.6), 0, 5.2);

  static Path _bars(Offset c, double r) {
    final p = Path();
    for (final dx in [-1.0, 0.0, 1.0]) {
      p.moveTo(c.dx + dx * r * 0.6, c.dy - r);
      p.lineTo(c.dx + dx * r * 0.6, c.dy + r);
    }
    return p;
  }

  static Path _peaks(Offset c, double r) => Path()
    ..moveTo(c.dx - r, c.dy + r * 0.6)
    ..lineTo(c.dx - r * 0.5, c.dy - r * 0.5)
    ..lineTo(c.dx, c.dy + r * 0.4)
    ..lineTo(c.dx + r * 0.5, c.dy - r * 0.5)
    ..lineTo(c.dx + r, c.dy + r * 0.6);

  static Path _hex(Offset c, double r) {
    final p = Path();
    for (var i = 0; i < 6; i++) {
      final a = -math.pi / 2 + i * math.pi / 3;
      final pt = c + Offset(r * 0.8 * math.cos(a), r * 0.8 * math.sin(a));
      i == 0 ? p.moveTo(pt.dx, pt.dy) : p.lineTo(pt.dx, pt.dy);
    }
    p.close();
    return p;
  }

  // ── Light bits ─────────────────────────────────────────────────────────

  void _paintSparkles(Canvas canvas, Paint fill) {
    for (final sx in [-1.0, 1.0]) {
      final sp = Offset(cx + sx * 3.8 * _u, cy - 4.0 * _u);
      final p = Path();
      final r = 1.2 * _u;
      for (var i = 0; i < 4; i++) {
        final a = math.pi / 4 + i * math.pi / 2;
        final pt = sp + Offset(r * math.cos(a), r * math.sin(a));
        i == 0 ? p.moveTo(pt.dx, pt.dy) : p.lineTo(pt.dx, pt.dy);
      }
      p.close();
      canvas.drawPath(p, fill);
    }
  }

  void _drawZmote(Canvas canvas, KeeperZmote z) {
    final p = z.base + Offset(0, -z.rise * 6 * _s / 84);
    if (motion.expression == KeeperExpression.inLove) {
      // Love pose floats white hearts up off the face (design particles).
      _drawInEye(
        canvas,
        p,
        (c) => c.drawPath(
          _kHeartPath(),
          Paint()..color = _fore.withValues(alpha: _value * z.alpha),
        ),
        scale: 0.5,
      );
      return;
    }
    final tp = TextPainter(
      text: TextSpan(
        text: 'z',
        style: TextStyle(
          fontFamily: 'JetBrainsMono',
          fontSize: 10 * _s / 84,
          color: tokens.textSecondary.withValues(alpha: z.alpha),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, p - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(KeeperPainter oldDelegate) =>
      oldDelegate.state != state ||
      oldDelegate.motion != motion ||
      oldDelegate.tokens != tokens;
}