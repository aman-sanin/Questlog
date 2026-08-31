import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../app/providers/database_provider.dart';
import '../../app/providers/profile_provider.dart';
import '../../app/providers/profile_view_provider.dart';
import '../../app/providers/today_provider.dart';
import '../../app/services/haptic_service.dart';
import '../../app/services/sound_service.dart';
import '../../domain/engine/quest_state.dart';
import '../../domain/model/models.dart';
import '../sheets/goal_detail_sheet.dart';
import '../sheets/quest_editor_sheet.dart';
import '../theme/tokens.dart';
import '../widgets/banner_widget.dart';
import '../widgets/chips.dart';
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

                // Perfect Day Banner
                if (state.isPerfectDayEarned)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: PerfectDayBanner(),
                    ),
                  ),

                // Empty State
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

                // Goal Sections
                for (final section in state.goalSections) ...[
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
                                  QuestEditorSheet.show(context, quest: questData);
                                }
                              },
                              onComplete: () => _handleComplete(ref, q, today, weekStart),
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
                if (state.generalQuests.isNotEmpty) ...[
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
                          final q = state.generalQuests[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: QuestRow(
                              evaluation: q,
                              onTap: () async {
                                final questData =
                                    await ref.read(questsDaoProvider).getQuestById(q.questId);
                                if (questData != null && context.mounted) {
                                  QuestEditorSheet.show(context, quest: questData);
                                }
                              },
                              onComplete: () => _handleComplete(ref, q, today, weekStart),
                              onIncrement: () => _handleComplete(ref, q, today, weekStart),
                              onDecrement: () => _handleDecrement(ref, q, today, weekStart),
                            ),
                          );
                        },
                        childCount: state.generalQuests.length,
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

  void _handleDecrement(WidgetRef ref, QuestEvaluation q, LocalDate today, WeekStart weekStart) async {
    HapticService.light();
    await ref.read(questActionsProvider).decrementQuest(
          questId: q.questId,
          date: today,
          weekStart: weekStart,
          now: DateTime.now(),
        );
  }
}
