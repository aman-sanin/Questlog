import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/providers/keeper_provider.dart';
import '../../domain/keeper/expressions.dart';
import '../../domain/keeper/growth.dart';
import '../../domain/keeper/tunables.dart';
import '../theme/tokens.dart';
import '../widgets/keeper_widget.dart';
import '../widgets/thought_bubble.dart';

/// The Keeper sheet (keeper.md §10): orb in current mood, a journal made of
/// derived facts, and the growth track in unlock-track styling. The thought
/// bubble above the face rotates the current expression's lines (§7).
class KeeperSheet extends ConsumerStatefulWidget {
  static Future<void> show(BuildContext context) {
    // The status-bar inset must be captured up here — the modal wraps its
    // content in MediaQuery.removePadding(top), so the sheet's own MediaQuery
    // reports padding.top == 0 (bottom_sheet.dart). We re-apply it below with
    // the height cap so a tall panel stops under the notification bar.
    final topInset = MediaQuery.paddingOf(context).top;
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => KeeperSheet(topInset: topInset),
    );
  }

  final double topInset;

  const KeeperSheet({super.key, this.topInset = 0});

  @override
  ConsumerState<KeeperSheet> createState() => _KeeperSheetState();
}

class _KeeperSheetState extends ConsumerState<KeeperSheet> {
  KeeperExpression? _face;

  void _onFaceExpression(KeeperExpression e) {
    if (e == _face) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || e == _face) return;
      setState(() => _face = e);
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final ui = ref.watch(keeperUiStateProvider);
    final journal = ref.watch(keeperJournalProvider);
    final bus = ref.read(keeperEventBusProvider);

    final expression =
        _face ?? resolveKeeperExpression(poses: const {}, mood: ui.mood);

    final rows = [
      (KeeperStage.summoned, 'SUMMONED', 'calling chosen'),
      (
        KeeperStage.waking,
        'WAKING',
        '${KeeperTunables.growthWaking} perfect days',
      ),
      (
        KeeperStage.adorned,
        'ADORNED',
        '${KeeperTunables.growthAdorned} perfect days',
      ),
      (
        KeeperStage.trimmed,
        'TRIMMED',
        '${KeeperTunables.growthTrimmed} perfect days',
      ),
      (
        KeeperStage.gilded,
        'GILDED',
        'level ${KeeperTunables.gildLevel} legend',
      ),
    ];

    // The whole panel is capped below the status bar (topInset is captured in
    // show() before the modal strips it), so a full journal + growth track
    // can't reach the notification bar. SafeArea keeps content above the
    // gesture/nav-bar buttons on the bottom, with a >=0 gap on legacy nav.
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height - widget.topInset,
      ),
      child: Container(
        key: const ValueKey('keeper-sheet-panel'),
        decoration: BoxDecoration(
          color: tokens.tonal,
          border: Border(top: BorderSide(color: tokens.lineRest, width: 1)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SafeArea(
          top: false,
          left: false,
          right: false,
          minimum: const EdgeInsets.only(bottom: 16),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: tokens.lineRule,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'THE KEEPER',
                    style: tokens.monoText(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                      color: tokens.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'The log remembers; the Keeper reads it.',
                    style: tokens.body(
                      fontSize: 12,
                      color: tokens.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      KeeperThoughtCarousel(expression: expression),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: 96,
                        height: 96,
                        child: KeeperWidget(
                          mood: ui.mood,
                          anticipation: ui.anticipation,
                          stage: ui.stage,
                          calling: ui.calling,
                          bus: bus,
                          size: 96,
                          onExpressionChanged: _onFaceExpression,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  'JOURNAL',
                  style: tokens.monoText(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                    color: tokens.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                _JournalTile(
                  label: 'DAYS KEPT COMPANY',
                  value: '${journal.daysKeptCompany}',
                ),
                _JournalTile(
                  label: 'PERFECT DAYS WITNESSED',
                  value: '${journal.perfectDays}',
                ),
                _JournalTile(
                  label: 'GOALS SEEN COMPLETED',
                  value: '${journal.goalsSeenCompleted}',
                ),
                _JournalTile(
                  label: 'LIKES BEST',
                  value: journal.favoriteQuest ?? '—',
                ),
                const SizedBox(height: 20),

                Text(
                  'GROWTH TRACK',
                  style: tokens.monoText(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                    color: tokens.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                for (var i = 0; i < rows.length; i++) ...[
                  _GrowthRow(
                    title: rows[i].$1.name.toUpperCase(),
                    subtitle: rows[i].$2,
                    earned: ui.stage.index >= rows[i].$1.index,
                    isEmber: rows[i].$1.index >= KeeperStage.trimmed.index,
                    progressToNext: i + 1 < rows.length
                        ? (ui.stage.index > i
                              ? 1.0
                              : (ui.stage.index == i
                                    ? (ui.stage == KeeperStage.gilded
                                          ? 1.0
                                          : (perfectDaysFraction(
                                              ui.perfectDays,
                                              rows[i].$1,
                                            )))
                                    : 0.0))
                        : 1.0,
                  ),
                  const SizedBox(height: 8),
                ],

                const SizedBox(height: 8),
                Divider(color: tokens.lineRule, height: 1),
                const SizedBox(height: 12),
                Text(
                  'It keeps the sealed shelf. It has watched ${journal.perfectDays} '
                  'perfect days happen. It cannot be harmed. It only grows.',
                  style: tokens.body(fontSize: 12, color: tokens.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static double perfectDaysFraction(int perfectDays, KeeperStage from) {
    final start = switch (from) {
      KeeperStage.summoned => 0,
      KeeperStage.waking => KeeperTunables.growthWaking,
      KeeperStage.adorned => KeeperTunables.growthAdorned,
      KeeperStage.trimmed => KeeperTunables.growthTrimmed,
      KeeperStage.gilded => 0,
    };
    final end = switch (from) {
      KeeperStage.summoned => KeeperTunables.growthWaking,
      KeeperStage.waking => KeeperTunables.growthAdorned,
      KeeperStage.adorned => KeeperTunables.growthTrimmed,
      KeeperStage.trimmed => 10000, // trimmed → gilded is level-gated
      KeeperStage.gilded => 0,
    };
    if (end <= start) return 0;
    return ((perfectDays - start) / (end - start)).clamp(0.0, 1.0);
  }
}

class _JournalTile extends StatelessWidget {
  final String label;
  final String value;
  const _JournalTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: tokens.bg,
        border: Border.all(color: tokens.lineRest, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: tokens.monoText(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              color: tokens.textSecondary,
            ),
          ),
          Text(
            value.toUpperCase(),
            style: tokens.monoText(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: tokens.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _GrowthRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool earned;
  final bool isEmber;
  final double progressToNext;
  const _GrowthRow({
    required this.title,
    required this.subtitle,
    required this.earned,
    required this.isEmber,
    required this.progressToNext,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final accent = isEmber
        ? tokens.hero
        : (earned ? tokens.accent : tokens.textSecondary);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: earned ? tokens.tonal : Colors.transparent,
        border: Border.all(
          color: earned ? tokens.lineRest : tokens.lineRule,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: earned ? accent : tokens.lineRule,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: tokens.monoText(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.9,
                    color: earned ? tokens.textPrimary : tokens.textSecondary,
                  ),
                ),
                Text(
                  subtitle.toUpperCase(),
                  style: tokens.monoText(
                    fontSize: 9,
                    color: tokens.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (!earned)
            SizedBox(
              width: 64,
              child: LinearProgressIndicator(
                value: progressToNext,
                minHeight: 2,
                backgroundColor: tokens.lineRule,
                color: tokens.accent,
              ),
            )
          else
            Text(
              'KEPT',
              style: tokens.monoText(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: accent,
              ),
            ),
        ],
      ),
    );
  }
}
