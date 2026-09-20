import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/app/providers/keeper_provider.dart';
import 'package:questlog/domain/keeper/classifier.dart';
import 'package:questlog/domain/keeper/expressions.dart';
import 'package:questlog/domain/keeper/growth.dart';
import 'package:questlog/domain/model/models.dart';
import 'package:questlog/ui/theme/tokens.dart';
import 'package:questlog/ui/widgets/keeper_widget.dart';
import 'package:questlog/ui/widgets/thought_bubble.dart';

final _updateGoldens = Platform.environment['UPDATE_GOLDENS'] == 'true';

Uint8List resolve(Uint8List? bytes) => bytes!;

Future<Uint8List> viewBytes(ui.Image image) async {
  final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  return data!.buffer.asUint8List();
}

Future<Uint8List> paintBytes(
  KeeperPaintState state,
  KeeperMotion motion,
  AppTokens tokens,
) async {
  final recorder = ui.PictureRecorder();
  KeeperPainter(
    state: state,
    motion: motion,
    tokens: tokens,
  ).paint(Canvas(recorder), Size(state.size, state.size));
  final image = await recorder.endRecording().toImage(
    state.size.toInt(),
    state.size.toInt(),
  );
  return viewBytes(image);
}

Future<Uint8List> paintLeakPad(
  KeeperPaintState state,
  KeeperMotion motion,
  AppTokens tokens,
) async {
  final size = state.size.toInt() + 8;
  final recorder = ui.PictureRecorder();
  KeeperPainter(
    state: state,
    motion: motion,
    tokens: tokens,
  ).paint(Canvas(recorder), Size(state.size, state.size));
  final image = await recorder.endRecording().toImage(size, size);
  return viewBytes(image);
}

Future<void> expectGolden(Uint8List actual, String name) async {
  final file = File('test/goldens/$name');
  if (_updateGoldens) {
    file.parent.createSync(recursive: true);
    file.writeAsBytesSync(actual);
    return;
  }
  expect(
    file.existsSync(),
    isTrue,
    reason:
        'golden missing: test/goldens/$name (regenerate by running '
        'UPDATE_GOLDENS=true flutter test test/keeper_render_test.dart)',
  );
  expect(
    actual,
    equals(file.readAsBytesSync()),
    reason: 'golden mismatch: test/goldens/$name',
  );
}

void main() {
  final dark = AppTokens.build(isDark: true, accentTheme: AccentTheme.frost);
  final light = AppTokens.build(isDark: false, accentTheme: AccentTheme.frost);

  KeeperPaintState stateFor(
    KeeperMood mood,
    KeeperStage stage,
    CallingDomain calling, {
    double size = 84,
  }) => KeeperPaintState(
    mood: mood,
    anticipation: false,
    stage: stage,
    calling: calling,
    summoned: true,
    size: size,
  );

  group('painter determinism (§1.9, §13)', () {
    testWidgets('same state+motion -> identical bytes', (tester) async {
      final a = resolve(
        await tester.runAsync(
          () => paintBytes(
            stateFor(
              KeeperMood.attentive,
              KeeperStage.waking,
              CallingDomain.warrior,
            ),
            KeeperMotion.staticMotion,
            dark,
          ),
        ),
      );
      final b = resolve(
        await tester.runAsync(
          () => paintBytes(
            stateFor(
              KeeperMood.attentive,
              KeeperStage.waking,
              CallingDomain.warrior,
            ),
            KeeperMotion.staticMotion,
            dark,
          ),
        ),
      );
      expect(a, equals(b));
    });

    testWidgets(
      'the six eye channels participate: a glance changes the image',
      (tester) async {
        final still = resolve(
          await tester.runAsync(
            () => paintBytes(
              stateFor(
                KeeperMood.attentive,
                KeeperStage.adorned,
                CallingDomain.sage,
              ),
              KeeperMotion.staticMotion,
              dark,
            ),
          ),
        );
        final glancing = resolve(
          await tester.runAsync(
            () => paintBytes(
              stateFor(
                KeeperMood.attentive,
                KeeperStage.adorned,
                CallingDomain.sage,
              ),
              const KeeperMotion(
                phase: 0.25,
                bobDy: 0,
                breathY: 1.0,
                gaze: Offset(8, 8),
                blink: 1.0,
                eyeWide: 1.0,
                pingProgress: -1,
                gildProgress: -1,
                celebrate: false,
                mouthPop: 0,
                wiggleDeg: 0,
                zmotes: [],
              ),
              dark,
            ),
          ),
        );
        expect(glancing, isNot(equals(still)));
      },
    );
  });

  group('bounds guarantee (§1.9)', () {
    for (final (mood, stage) in [
      (KeeperMood.dormant, KeeperStage.summoned),
      (KeeperMood.content, KeeperStage.gilded),
    ]) {
      testWidgets('$mood @ $stage: nothing painted outside the S x S box', (
        tester,
      ) async {
        final state = KeeperPaintState(
          mood: mood,
          anticipation: false,
          stage: stage,
          calling: CallingDomain.warrior,
          summoned: true,
          size: 84,
        );
        final bytes = resolve(
          await tester.runAsync(
            () => paintLeakPad(state, KeeperMotion.staticMotion, dark),
          ),
        );
        final stride = 92;
        for (var y = 0; y < stride; y++) {
          for (var x = 0; x < stride; x++) {
            if (x >= 84 || y >= 84) {
              expect(
                bytes[(y * stride + x) * 4 + 3],
                0,
                reason: 'paint leaked past the box at ($x,$y)',
              );
            }
          }
        }
      });
    }
  });

  group('mood x stage x calling goldens (§13)', () {
    testWidgets('all moods at adorned (dark)', (tester) async {
      for (final mood in KeeperMood.values) {
        final bytes = resolve(
          await tester.runAsync(
            () => paintBytes(
              stateFor(mood, KeeperStage.adorned, CallingDomain.warrior),
              KeeperMotion.staticMotion,
              dark,
            ),
          ),
        );
        await tester.runAsync(
          () => expectGolden(bytes, 'keeper_mood_${mood.name}.bin'),
        );
      }
    });

    testWidgets('all six glyphs at waking (dark)', (tester) async {
      for (final calling in CallingDomain.values) {
        final bytes = resolve(
          await tester.runAsync(
            () => paintBytes(
              stateFor(KeeperMood.content, KeeperStage.waking, calling),
              KeeperMotion.staticMotion,
              dark,
            ),
          ),
        );
        await tester.runAsync(
          () => expectGolden(bytes, 'keeper_glyph_${calling.name}.bin'),
        );
      }
    });

    testWidgets('light theme renders distinct', (tester) async {
      final bytes = resolve(
        await tester.runAsync(
          () => paintBytes(
            stateFor(
              KeeperMood.content,
              KeeperStage.trimmed,
              CallingDomain.warrior,
            ),
            KeeperMotion.staticMotion,
            light,
          ),
        ),
      );
      await tester.runAsync(
        () => expectGolden(bytes, 'keeper_light_content_trimmed.bin'),
      );
    });

    testWidgets('gilded + gild-flash differ from malevolent-adjacent stages', (
      tester,
    ) async {
      final base = resolve(
        await tester.runAsync(
          () => paintBytes(
            stateFor(
              KeeperMood.content,
              KeeperStage.adorned,
              CallingDomain.warrior,
            ),
            KeeperMotion.staticMotion,
            dark,
          ),
        ),
      );
      final gilded = resolve(
        await tester.runAsync(
          () => paintBytes(
            stateFor(
              KeeperMood.content,
              KeeperStage.gilded,
              CallingDomain.warrior,
            ),
            const KeeperMotion(
              phase: 0.25,
              bobDy: 0,
              breathY: 1.0,
              gaze: Offset.zero,
              blink: 1.0,
              eyeWide: 1.0,
              pingProgress: -1,
              gildProgress: 0.5,
              celebrate: false,
              mouthPop: 0,
              wiggleDeg: 0,
              zmotes: [],
            ),
            dark,
          ),
        ),
      );
      expect(hexEqual(gilded, base), isFalse);
    });
  });

  group('expression goldens (§7)', () {
    KeeperMotion stillExpr(KeeperExpression expr) => KeeperMotion(
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
          expression: expr,
          zmotes: const [],
        );

    testWidgets('all nine expressions paint distinct goldens (dark)', (
      tester,
    ) async {
      Uint8List? last;
      for (final expr in KeeperExpression.values) {
        final bytes = resolve(
          await tester.runAsync(
            () => paintBytes(
              stateFor(
                KeeperMood.content,
                KeeperStage.adorned,
                CallingDomain.warrior,
              ),
              stillExpr(expr),
              dark,
            ),
          ),
        );
        if (last != null) {
          expect(
            hexEqual(bytes, last),
            isFalse,
            reason: '$expr must render differently from its predecessor',
          );
        }
        last = Uint8List.fromList(bytes);
        await tester.runAsync(
          () => expectGolden(bytes, 'keeper_expr_${expr.name}.bin'),
        );
      }
    });

    testWidgets('posing the Keeper never breaks the bounds guarantee (§1.9)', (
      tester,
    ) async {
      for (final expr in KeeperExpression.values) {
        final state = KeeperPaintState(
          mood: KeeperMood.content,
          anticipation: false,
          stage: KeeperStage.adorned,
          calling: CallingDomain.warrior,
          summoned: true,
          size: 84,
        );
        final bytes = resolve(
          await tester.runAsync(() => paintLeakPad(state, stillExpr(expr), dark)),
        );
        final stride = 92;
        for (var y = 0; y < stride; y++) {
          for (var x = 0; x < stride; x++) {
            if (x >= 84 || y >= 84) {
              expect(
                bytes[(y * stride + x) * 4 + 3],
                0,
                reason: 'expression $expr painted past the box at ($x,$y)',
              );
            }
          }
        }
      }
    });

    testWidgets(
      'blink squashes the capsule: a shut eye is not an open eye (§7)',
      (tester) async {
        final open = resolve(
          await tester.runAsync(
            () => paintBytes(
              stateFor(
                KeeperMood.content,
                KeeperStage.adorned,
                CallingDomain.warrior,
              ),
              stillExpr(KeeperExpression.happy),
              dark,
            ),
          ),
        );
        final shut = resolve(
          await tester.runAsync(
            () => paintBytes(
              stateFor(
                KeeperMood.content,
                KeeperStage.adorned,
                CallingDomain.warrior,
              ),
              const KeeperMotion(
                phase: 0.25,
                bobDy: 0,
                breathY: 1.0,
                gaze: Offset.zero,
                blink: 0.08,
                eyeWide: 1.0,
                pingProgress: -1,
                gildProgress: -1,
                celebrate: false,
                mouthPop: 0,
                wiggleDeg: 0,
                expression: KeeperExpression.happy,
                zmotes: [],
              ),
              dark,
            ),
          ),
        );
        expect(
          hexEqual(open, shut),
          isFalse,
          reason: 'the design blink (scaleY 0.08) must flatten the capsule',
        );
      },
    );

    testWidgets(
      'the love pose floats white hearts off the face (§7)',
      (tester) async {
        KeeperMotion love(List<KeeperZmote> zmotes) => KeeperMotion(
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
              expression: KeeperExpression.inLove,
              zmotes: zmotes,
            );
        const zmote = KeeperZmote(
          base: Offset(20, 30),
          rise: 0.5,
          alpha: 0.5,
        );
        final quiet = resolve(
          await tester.runAsync(
            () => paintBytes(
              stateFor(
                KeeperMood.content,
                KeeperStage.adorned,
                CallingDomain.warrior,
              ),
              love(const []),
              dark,
            ),
          ),
        );
        final smitten = resolve(
          await tester.runAsync(
            () => paintBytes(
              stateFor(
                KeeperMood.content,
                KeeperStage.adorned,
                CallingDomain.warrior,
              ),
              love(const [zmote, zmote]),
              dark,
            ),
          ),
        );
        expect(
          hexEqual(quiet, smitten),
          isFalse,
          reason: 'in-love zmotes must render as floating hearts',
        );
      },
    );
  });

  group('gestures (§7)', () {
    Widget wrap(Widget child) => MediaQuery(
          data: const MediaQueryData(size: Size(96, 96)),
          child: Theme(
            data: ThemeData(extensions: [dark]),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Center(child: child),
            ),
          ),
        );

    Future<void> pumpFace(
      WidgetTester tester, {
      KeeperMood mood = KeeperMood.content,
      VoidCallback? onLongPress,
    }) async {
      await tester.pumpWidget(
        wrap(
          KeeperWidget(
            mood: mood,
            calling: CallingDomain.warrior,
            size: 96,
            onLongPress: onLongPress,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 60));
    }

    testWidgets('a tap is a boop: recoil + surprise-widen run, then settle', (
      tester,
    ) async {
      await pumpFace(tester);
      final center = tester.getCenter(find.byType(KeeperWidget));
      final gesture = await tester.startGesture(
        center,
        kind: PointerDeviceKind.touch,
      );
      await tester.pump(const Duration(milliseconds: 20));
      await gesture.up();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 60));
      expect(
        _motionOf(tester).recoil,
        greaterThan(0),
        reason: 'the boop should sink-and-pop the recoil channel',
      );
      await tester.pump(const Duration(milliseconds: 400));
      expect(_motionOf(tester).recoil, 0);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('rapid taps tickle: dizzy spin + cheeky expression', (
      tester,
    ) async {
      await pumpFace(tester);
      final center = tester.getCenter(find.byType(KeeperWidget));
      for (var i = 0; i < 3; i++) {
        await tester.tapAt(center, kind: PointerDeviceKind.touch);
        await tester.pump(const Duration(milliseconds: 120));
      }
      await tester.pump(const Duration(milliseconds: 200));
      expect(
        _motionOf(tester).expression,
        KeeperExpression.cheeky,
        reason: 'a burst of taps should read as a playful tickle',
      );
      expect(_motionOf(tester).dizzy, greaterThan(0));
      await tester.pump(const Duration(milliseconds: 1600));
      expect(
        _motionOf(tester).expression,
        isNot(KeeperExpression.cheeky),
        reason: 'the cheeky pose should self-clear',
      );
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('dragging strokes: affection saturates into inLove hearts', (
      tester,
    ) async {
      await pumpFace(tester);
      final center = tester.getCenter(find.byType(KeeperWidget));
      final gesture = await tester.startGesture(
        center - const Offset(40, 0),
        kind: PointerDeviceKind.touch,
      );
      for (var i = 0; i < 12; i++) {
        await gesture.moveBy(const Offset(6, 0));
        await tester.pump(const Duration(milliseconds: 40));
      }
      await gesture.up();
      await tester.pump();
      expect(
        _motionOf(tester).expression,
        KeeperExpression.inLove,
        reason: 'enough stroking should earn the heart eyes',
      );
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('hover gaze: the eyes follow the pointer, then drift back', (
      tester,
    ) async {
      await pumpFace(tester);
      final center = tester.getCenter(find.byType(KeeperWidget));
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: center);
      await tester.pump();
      await mouse.moveTo(center + const Offset(40, 0));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 160));
      expect(
        _motionOf(tester).gaze.dx,
        greaterThan(0),
        reason: 'the gaze should track the hovering pointer',
      );
      await mouse.moveTo(center + const Offset(400, 0));
      for (var i = 0; i < 12; i++) {
        await tester.pump(const Duration(milliseconds: 33));
      }
      expect(
        _motionOf(tester).gaze.dx,
        lessThan(2),
        reason: 'leaving the face should let the gaze settle',
      );
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('long-press opens the sheet callback and is not a boop', (
      tester,
    ) async {
      var opened = false;
      await pumpFace(tester, onLongPress: () => opened = true);
      final center = tester.getCenter(find.byType(KeeperWidget));
      await tester.startGesture(center, kind: PointerDeviceKind.touch);
      await tester.pump(const Duration(milliseconds: 600));
      expect(opened, isTrue, reason: 'the long-press should fire the callback');
      expect(_motionOf(tester).recoil, 0);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('bus pet still purrs even under reduced motion (no motion)', (
      tester,
    ) async {
      final tokens = dark;
      final bus = KeeperEventBus();
      addTearDown(bus.dispose);
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            disableAnimations: true,
            size: Size(96, 96),
          ),
          child: Theme(
            data: ThemeData(extensions: [tokens]),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Center(
                child: KeeperWidget(
                  mood: KeeperMood.content,
                  calling: CallingDomain.warrior,
                  size: 96,
                  bus: bus,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));
      bus.post(kind: KeeperEventKind.pet);
      await tester.pump(const Duration(milliseconds: 50));
      final m = _motionOf(tester);
      expect(m.expression, KeeperExpression.happy);
      expect(m.recoil, 0);
      expect(m.wiggleDeg, 0);
      await tester.pumpWidget(const SizedBox());
    });
  });

  group('thought bubbles (§7)', () {
    Widget wrap(Widget child) {
      return Theme(
        data: ThemeData(extensions: [dark]),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Center(child: child),
        ),
      );
    }

    testWidgets('the bubble shows the current expression line and rotates', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(const KeeperThoughtCarousel(expression: KeeperExpression.shocked)),
      );
      expect(find.text('Oh.'), findsOneWidget);
      await tester.pump(const Duration(seconds: 7));
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text('That was rare.'), findsOneWidget);
      expect(find.text('Oh.'), findsNothing);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('a fresh expression restarts the rotation', (tester) async {
      await tester.pumpWidget(
        wrap(const KeeperThoughtCarousel(expression: KeeperExpression.happy)),
      );
      await tester.pumpWidget(
        wrap(const KeeperThoughtCarousel(expression: KeeperExpression.grumpy)),
      );
      expect(find.text('Too much, too much.'), findsOneWidget);
      await tester.pump(const Duration(seconds: 7));
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text('I will sulk. Briefly.'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('the face reports its live expression for the bubble', (
      tester,
    ) async {
      final bus = KeeperEventBus();
      addTearDown(bus.dispose);
      KeeperExpression? last;
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(96, 96)),
          child: Theme(
            data: ThemeData(extensions: [dark]),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Center(
                child: KeeperWidget(
                  mood: KeeperMood.content,
                  calling: CallingDomain.warrior,
                  size: 96,
                  bus: bus,
                  onExpressionChanged: (e) => last = e,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 60));
      expect(last, KeeperExpression.happy);
      bus.post(kind: KeeperEventKind.complete, cadence: Cadence.weekly);
      await tester.pump(const Duration(milliseconds: 60));
      expect(last, KeeperExpression.shocked);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(const SizedBox());
    });
  });

  group('mouth-sync (§4/§13)', () {
    // The widget's own rebuild pipeline is watched: CustomPaint is built from
    // KeeperMotion every frame, so the hook is observable without rasterizing
    // (toImage is unreliable while an animation keeps scheduling frames).
    testWidgets(
      'a daily chirp pops the mouth ~150ms and returns; deleting the '
      'mouth-sync hook breaks it',
      (tester) async {
        final tokens = dark;
        final bus = KeeperEventBus();
        addTearDown(bus.dispose);
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(96, 96)),
            child: Theme(
              data: ThemeData(extensions: [tokens]),
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: Center(
                  child: KeeperWidget(
                    mood: KeeperMood.attentive,
                    calling: CallingDomain.warrior,
                    size: 96,
                    bus: bus,
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));
        expect(_motionOf(tester).mouthPop, 0);

        // Daily complete with no glance/ping noise — the only lever left is
        // the mouth-sync pop.
        bus.post(
          kind: KeeperEventKind.complete,
          cadence: Cadence.daily,
          at: null,
        );
        // First frame arms the controller; the next advances ~pop/2.
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 40));
        expect(
          _motionOf(tester).mouthPop,
          greaterThan(0),
          reason: 'the chirp must open the mouth while the hook is wired',
        );

        // The pop self-terminates (tap ~150ms).
        await tester.pump(const Duration(milliseconds: 200));
        expect(_motionOf(tester).mouthPop, 0);
        await tester.pumpWidget(const SizedBox());
      },
    );

    testWidgets(
      'painter: mouthPop renders, giving the hook a visible target',
      (tester) async {
        final still = resolve(
          await tester.runAsync(
            () => paintBytes(
              stateFor(
                KeeperMood.attentive,
                KeeperStage.waking,
                CallingDomain.warrior,
                size: 96,
              ),
              const KeeperMotion(
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
              ),
              dark,
            ),
          ),
        );
        final popping = resolve(
          await tester.runAsync(
            () => paintBytes(
              stateFor(
                KeeperMood.attentive,
                KeeperStage.waking,
                CallingDomain.warrior,
                size: 96,
              ),
              const KeeperMotion(
                phase: 0.25,
                bobDy: 0,
                breathY: 1.0,
                gaze: Offset.zero,
                blink: 1.0,
                eyeWide: 1.0,
                pingProgress: -1,
                gildProgress: -1,
                celebrate: false,
                mouthPop: 1,
                wiggleDeg: 0,
                zmotes: [],
              ),
              dark,
            ),
          ),
        );
        expect(popping, isNot(equals(still)));
      },
    );
  });

  group('unsummoned silhouette wakes (§8)', () {
    KeeperPaintState unsummoned(KeeperMood mood) => KeeperPaintState(
          mood: mood,
          anticipation: false,
          stage: KeeperStage.summoned,
          calling: null,
          summoned: false,
          size: 84,
        );

    testWidgets(
      'pre-calling: closed while day untouched, eyes open the moment a '
      'single quest is completed — and the silhouette still bears no glyph',
      (tester) async {
        final asleep = resolve(
          await tester.runAsync(
            () => paintBytes(
              unsummoned(KeeperMood.dormant),
              KeeperMotion.staticMotion,
              dark,
            ),
          ),
        );
        final watching = resolve(
          await tester.runAsync(
            () => paintBytes(
              unsummoned(KeeperMood.attentive),
              KeeperMotion.staticMotion,
              dark,
            ),
          ),
        );
        final contentSmile = resolve(
          await tester.runAsync(
            () => paintBytes(
              unsummoned(KeeperMood.content),
              KeeperMotion.staticMotion,
              dark,
            ),
          ),
        );

        // Completing anything today must open the eyes (dormant -> awake).
        expect(watching, isNot(equals(asleep)));
        expect(contentSmile, isNot(equals(asleep)));

        // And the wake must be real: an open eye is the 28x44 design capsule
        // (44k ≈ 19px tall), while the sleeping lid is a 0.15u line. Scan a
        // column inside the capsule (s=84 → k=0.4375, eye spread 0.92 →
        // right eye centre = 42 + 64k*0.92 ≈ 67.8, capsule spans 61.6..73.9;
        // the robo face has no pupils — the whole capsule is solid).
        const stride = 84;
        const colX = 63; // inside the solid capsule
        expect(
          fgRowSpan(asleep, colX, stride),
          lessThanOrEqualTo(5),
          reason: 'a sleeping lid is a thin closed line',
        );
        expect(
          fgRowSpan(watching, colX, stride),
          greaterThanOrEqualTo(10),
          reason: 'an attentive eye is an open capsule once a quest is done',
        );

        // Acceptance gate 8: the pre-calling face stays a bare silhouette —
        // the glyph strip above the eye row is empty at summoning stage.
        for (var y = 6; y < 13; y++) {
          for (var x = 0; x < stride; x++) {
            expect(
              watching[(y * stride + x) * 4 + 3],
              0,
              reason: 'silhouette must not draw a glyph at ($x,$y)',
            );
          }
        }
      },
    );
  });

  group('reduced motion (§1.10)', () {
    testWidgets('disableAnimations -> static canonical pose, no frame loop', (
      tester,
    ) async {
      final tokens = dark;
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            disableAnimations: true,
            size: Size(84, 84),
          ),
          child: Theme(
            data: ThemeData(extensions: [tokens]),
            child: const Directionality(
              textDirection: TextDirection.ltr,
              child: Center(
                child: RepaintBoundary(
                  child: KeeperWidget(mood: KeeperMood.attentive, size: 84),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 1));
      expect(tester.binding.transientCallbackCount, 0);
      final first = resolve(
        await tester.runAsync(() => _captureWidget(tester)),
      );
      // The static frame must equal the canonical frozen pose — no bobbed or
      // breath-scaled silhouette, even though no frame loop is running.
      final canonical = resolve(
        await tester.runAsync(
          () => paintBytes(
            const KeeperPaintState(
              mood: KeeperMood.attentive,
              anticipation: false,
              stage: KeeperStage.summoned,
              calling: null,
              summoned: false,
              size: 84,
            ),
            KeeperMotion.staticMotion,
            tokens,
          ),
        ),
      );
      expect(first, equals(canonical));
      await tester.pump(const Duration(seconds: 1));
      final second = resolve(
        await tester.runAsync(() => _captureWidget(tester)),
      );
      expect(second, equals(first));
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets(
      'control: animations enabled -> moving motion, transient callbacks '
      'run',
      (tester) async {
        final tokens = dark;
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(84, 84)),
            child: Theme(
              data: ThemeData(extensions: [tokens]),
              child: const Directionality(
                textDirection: TextDirection.ltr,
                child: Center(
                  child: KeeperWidget(mood: KeeperMood.content),
                ),
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));
        expect(tester.binding.transientCallbackCount, greaterThan(0));
        final m1 = _motionOf(tester);
        await tester.pump(const Duration(seconds: 1));
        final m2 = _motionOf(tester);
        expect(
          m2.phase != m1.phase || m2.bobDy != m1.bobDy,
          isTrue,
          reason: 'animations enabled should move the face',
        );
        await tester.pumpWidget(const SizedBox());
      },
    );
  });
}

bool hexEqual(Uint8List a, Uint8List b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// Longest run of opaque-foreground rows down a pixel column in the raw RGBA
/// buffer — an open eye is a tall block, a closed lid a thin line.
int fgRowSpan(Uint8List bytes, int x, int stride) {
  var best = 0, run = 0;
  for (var y = 0; y < stride; y++) {
    if (bytes[(y * stride + x) * 4 + 3] > 0) {
      run++;
      if (run > best) best = run;
    } else {
      run = 0;
    }
  }
  return best;
}

Future<Uint8List> _captureWidget(WidgetTester tester) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byType(RepaintBoundary),
  );
  final image = await boundary.toImage(pixelRatio: 1);
  final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  return data!.buffer.asUint8List();
}

KeeperMotion _motionOf(WidgetTester tester) {
  final paint = tester.widget<CustomPaint>(
    find.descendant(
      of: find.byType(KeeperWidget),
      matching: find.byType(CustomPaint),
    ),
  );
  return (paint.painter! as KeeperPainter).motion;
}
