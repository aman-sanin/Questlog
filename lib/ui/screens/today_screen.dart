import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../app/providers/coach_provider.dart';
import '../../app/providers/database_provider.dart';
import '../../app/providers/profile_provider.dart';
import '../../app/providers/profile_view_provider.dart';
import '../../app/providers/today_provider.dart';
import '../../app/services/haptic_service.dart';
import '../../app/services/sound_service.dart';
import '../../domain/engine/coach.dart';
import '../../domain/engine/quest_state.dart';
import '../../domain/model/models.dart';
import '../sheets/goal_detail_sheet.dart';
import '../sheets/quest_detail_sheet.dart';
import '../sheets/quest_editor_sheet.dart';
import '../sheets/triage_sheet.dart';
import '../theme/tokens.dart';
import '../widgets/action_button.dart';
import '../widgets/app_input.dart';
import '../widgets/banner_widget.dart';
import '../widgets/chips.dart';
import '../widgets/coach_card_widget.dart';
import '../widgets/completion_ring.dart';
import '../widgets/quest_row.dart';
import '../widgets/sigil_widget.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final todayStateAsync = ref.watch(todayStateProvider);
    final profileViewAsync = ref.watch(profileViewStateProvider);
    final coachSignalAsync = ref.watch(activeCoachSignalProvider);
    final coachSignal = coachSignalAsync.value;
    final today = ref.watch(effectiveLocalDateProvider);
    final weekStart = ref.watch(weekStartProvider);

    final String dateHeader = DateFormat('EEEE, MMM d').format(today.toDateTime()).toUpperCase();

    return Scaffold(
      backgroundColor: tokens.bg,
      body: SafeArea(
        child: todayStateAsync.when(
          loading: () => Center(
            child: CircularProgressIndicator(color: tokens.accent),
          ),
          error: (err, stack) => Center(
            child: Text('Error: $err', style: tokens.monoText(color: tokens.miss)),
          ),
          data: (state) {
            final int currentLevel = profileViewAsync.value?.progression.level ?? 1;
            final activeFilter = ref.watch(todayCadenceFilterProvider);

            // Filter goal sections
            final filteredGoalSections = state.goalSections.map((section) {
              if (activeFilter == null) return section;
              final filteredQuests =
                  section.quests.where((q) => q.rule.cadence == activeFilter).toList();
              return GoalSectionViewModel(
                goal: section.goal,
                completionRate: section.completionRate,
                quests: filteredQuests,
              );
            }).where((section) => section.quests.isNotEmpty).toList();

            // Filter general quests
            final filteredGeneralQuests = activeFilter == null
                ? state.generalQuests
                : state.generalQuests.where((q) => q.rule.cadence == activeFilter).toList();

            final hasQuestsMatchingFilter =
                filteredGoalSections.isNotEmpty || filteredGeneralQuests.isNotEmpty;

            return CustomScrollView(
              slivers: [
                // Top App Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TODAY',
                              style: tokens.monoText(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.2,
                                color: tokens.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              dateHeader,
                              style: tokens.headline(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: tokens.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        LevelChip(
                          level: currentLevel,
                          onTap: () => context.go('/profile'),
                        ),
                      ],
                    ),
                  ),
                ),

                // Top Coach Card (max one)
                if (coachSignal != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
                      child: CoachCardWidget(
                        title: coachSignal.title,
                        message: coachSignal.message,
                        onDismiss: () {
                          ref.read(coachControllerProvider).dismiss(coachSignal);
                        },
                        actions: coachSignal.actions.map((act) {
                          return CoachCardAction(
                            label: act.label,
                            isPrimary: act.type != CoachActionType.dismiss,
                            onTap: () => _handleCoachAction(context, ref, coachSignal, act, today),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                // Perfect Day Banner
                if (state.isPerfectDayEarned)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: PerfectDayBanner(),
                    ),
                  ),

                // Cadence Filter Bar
                if (!state.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _CadenceFilterBar(state: state),
                    ),
                  ),

                // Empty State (no active quests at all)
                if (state.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SigilWidget(
                            domain: CallingDomain.warrior,
                            size: 64,
                            mode: SigilMode.watermark,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'YOUR DAY IS UNWRITTEN',
                            style: tokens.title(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: tokens.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Tap + below to author your first quest.',
                            style: tokens.body(
                              fontSize: 13,
                              color: tokens.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Empty Filtered State (quests exist, but none match current cadence filter)
                if (!state.isEmpty && !hasQuestsMatchingFilter)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Symbols.filter_alt_off, size: 36, color: tokens.textSecondary),
                          const SizedBox(height: 12),
                          Text(
                            'NO ${activeFilter!.name.toUpperCase()} QUESTS',
                            style: tokens.monoText(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.0,
                              color: tokens.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 14),
                          GestureDetector(
                            onTap: () => ref.read(todayCadenceFilterProvider.notifier).state = null,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: tokens.tonal,
                                border: Border.all(color: tokens.lineRule, width: 1),
                              ),
                              child: Text(
                                'SHOW ALL',
                                style: tokens.monoText(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                  color: tokens.accent,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Goal Sections
                for (final section in filteredGoalSections) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: InkWell(
                        onTap: () => GoalDetailSheet.show(
                          context,
                          goal: section.goal,
                          quests: section.quests,
                          completionRate: section.completionRate,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  section.goal.emoji,
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  section.goal.title.toUpperCase(),
                                  style: tokens.monoText(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.0,
                                    color: tokens.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            CompletionRing(
                              progress: section.completionRate,
                              size: 18,
                              strokeWidth: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final q = section.quests[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: QuestRow(
                              evaluation: q,
                              onTap: () async {
                                final questData =
                                    await ref.read(questsDaoProvider).getQuestById(q.questId);
                                if (questData != null && context.mounted) {
                                  QuestDetailSheet.show(context, quest: questData, evaluation: q);
                                }
                              },
                              onLongPress: () async {
                                final questData =
                                    await ref.read(questsDaoProvider).getQuestById(q.questId);
                                if (questData != null && context.mounted) {
                                  QuestEditorSheet.show(context, quest: questData);
                                }
                              },
                              onComplete: () => _handleComplete(ref, q, today, weekStart),
                              onLongPressCheckbox: () =>
                                  _handleLogWithNote(context, ref, q, today, weekStart),
                              onIncrement: () => _handleComplete(ref, q, today, weekStart),
                              onDecrement: () => _handleDecrement(ref, q, today, weekStart),
                            ),
                          );
                        },
                        childCount: section.quests.length,
                      ),
                    ),
                  ),
                ],

                // General Quests Section
                if (filteredGeneralQuests.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                      child: Text(
                        'GENERAL',
                        style: tokens.monoText(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.0,
                          color: tokens.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final q = filteredGeneralQuests[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: QuestRow(
                              evaluation: q,
                              onTap: () async {
                                final questData =
                                    await ref.read(questsDaoProvider).getQuestById(q.questId);
                                if (questData != null && context.mounted) {
                                  QuestDetailSheet.show(context, quest: questData, evaluation: q);
                                }
                              },
                              onLongPress: () async {
                                final questData =
                                    await ref.read(questsDaoProvider).getQuestById(q.questId);
                                if (questData != null && context.mounted) {
                                  QuestEditorSheet.show(context, quest: questData);
                                }
                              },
                              onComplete: () => _handleComplete(ref, q, today, weekStart),
                              onLongPressCheckbox: () =>
                                  _handleLogWithNote(context, ref, q, today, weekStart),
                              onIncrement: () => _handleComplete(ref, q, today, weekStart),
                              onDecrement: () => _handleDecrement(ref, q, today, weekStart),
                            ),
                          );
                        },
                        childCount: filteredGeneralQuests.length,
                      ),
                    ),
                  ),
                ],

                const SliverToBoxAdapter(
                  child: SizedBox(height: 100), // Bottom padding for FAB monolith
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _handleComplete(WidgetRef ref, QuestEvaluation q, LocalDate today, WeekStart weekStart) async {
    HapticService.light();
    SoundService.playCheck();

    final questData = await ref.read(questsDaoProvider).getQuestById(q.questId);
    if (questData != null) {
      await ref.read(questActionsProvider).completeQuest(
            quest: questData,
            date: today,
            weekStart: weekStart,
            now: DateTime.now(),
          );
    }
  }

  void _handleLogWithNote(
    BuildContext context,
    WidgetRef ref,
    QuestEvaluation q,
    LocalDate today,
    WeekStart weekStart,
  ) async {
    final controller = TextEditingController();
    final tokens = context.tokens;

    final note = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: tokens.bg,
            border: Border(top: BorderSide(color: tokens.accent, width: 2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'LOG WITH NOTE',
                style: tokens.headline(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: tokens.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                q.title,
                style: tokens.body(fontSize: 13, color: tokens.textSecondary),
              ),
              const SizedBox(height: 16),
              AppInput(
                controller: controller,
                hintText: 'Add an optional note about this session...',
                autofocus: true,
              ),
              const SizedBox(height: 16),
              ActionButton(
                label: 'COMPLETE WITH NOTE',
                variant: ActionButtonVariant.primary,
                onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
              ),
            ],
          ),
        ),
      ),
    );

    if (note != null) {
      HapticService.light();
      SoundService.playCheck();
      final questData = await ref.read(questsDaoProvider).getQuestById(q.questId);
      if (questData != null) {
        await ref.read(questActionsProvider).completeQuest(
              quest: questData,
              date: today,
              note: note.isEmpty ? null : note,
              weekStart: weekStart,
              now: DateTime.now(),
            );
      }
    }
  }

  void _handleDecrement(WidgetRef ref, QuestEvaluation q, LocalDate today, WeekStart weekStart) async {
    HapticService.light();
    await ref.read(questActionsProvider).decrementQuest(
          questId: q.questId,
          date: today,
          weekStart: weekStart,
          now: DateTime.now(),
        );
  }

  Future<void> _handleCoachAction(
    BuildContext context,
    WidgetRef ref,
    CoachSignal signal,
    CoachAction action,
    LocalDate today,
  ) async {
    final controller = ref.read(coachControllerProvider);
    final questActions = ref.read(questActionsProvider);

    switch (action.type) {
      case CoachActionType.dismiss:
      case CoachActionType.understood:
      case CoachActionType.continueFlow:
        await controller.dismiss(signal);
        break;

      case CoachActionType.raiseTarget:
        final questId = action.payload['questId'] as String;
        final targetValue = action.payload['targetValue'] as int;
        await questActions.updateTargetValue(questId, targetValue);
        await controller.markAccepted(signal);
        break;

      case CoachActionType.raiseDifficulty:
        final questId = action.payload['questId'] as String;
        final difficulty = action.payload['difficulty'] as Difficulty;
        await questActions.updateDifficulty(questId, difficulty);
        await controller.markAccepted(signal);
        break;

      case CoachActionType.pause:
        final questId = action.payload['questId'] as String;
        final days = action.payload['days'] as int? ?? 14;
        await questActions.pauseQuest(questId, today.addDays(days));
        await controller.markAccepted(signal);
        break;

      case CoachActionType.archive:
        final questId = action.payload['questId'] as String;
        await questActions.archiveQuest(questId, today.toDateTime());
        await controller.markAccepted(signal);
        break;

      case CoachActionType.export:
        await controller.markAccepted(signal);
        if (context.mounted) {
          context.push('/settings');
        }
        break;

      case CoachActionType.reviewLoad:
        await controller.markAccepted(signal);
        if (context.mounted) {
          await TriageSheet.show(context, questIds: signal.relatedQuestIds ?? []);
        }
        break;

      case CoachActionType.suggestCadence:
      case CoachActionType.lowerTarget:
        final questId = action.payload?['questId'] as String?;
        await controller.markAccepted(signal);
        if (questId != null && context.mounted) {
          final questData = await ref.read(questsDaoProvider).getQuestById(questId);
          if (questData != null && context.mounted) {
            QuestEditorSheet.show(context, quest: questData);
          }
        }
        break;
    }
  }
}

class _CadenceFilterBar extends ConsumerWidget {
  final TodayScreenState state;

  const _CadenceFilterBar({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeFilter = ref.watch(todayCadenceFilterProvider);

    const cadences = [
      Cadence.daily,
      Cadence.weekly,
      Cadence.monthly,
      Cadence.yearly,
      Cadence.single,
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _FilterChipItem(
            label: 'ALL',
            count: state.allQuests.length,
            isSelected: activeFilter == null,
            onTap: () => ref.read(todayCadenceFilterProvider.notifier).state = null,
          ),
          for (final c in cadences) ...[
            const SizedBox(width: 6),
            _FilterChipItem(
              label: c.name.toUpperCase(),
              count: state.allQuests.where((q) => q.rule.cadence == c).length,
              isSelected: activeFilter == c,
              onTap: () {
                final current = ref.read(todayCadenceFilterProvider);
                ref.read(todayCadenceFilterProvider.notifier).state = current == c ? null : c;
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _FilterChipItem extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChipItem({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? tokens.accent : tokens.tonal,
          border: Border.all(
            color: isSelected ? tokens.accent : tokens.lineRule,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: tokens.monoText(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                letterSpacing: 0.6,
                color: isSelected ? tokens.onSolid : tokens.textSecondary,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected ? tokens.onSolid.withOpacity(0.2) : tokens.lineRule.withOpacity(0.4),
                ),
                child: Text(
                  '$count',
                  style: tokens.monoText(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? tokens.onSolid : tokens.textSecondary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
