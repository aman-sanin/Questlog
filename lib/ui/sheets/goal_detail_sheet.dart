import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../app/providers/ceremony_provider.dart';
import '../../app/providers/database_provider.dart';
import '../../app/providers/profile_provider.dart';
import '../../data/db/database.dart';
import '../../domain/engine/quest_state.dart';
import '../theme/tokens.dart';
import '../widgets/action_button.dart';
import '../widgets/completion_ring.dart';
import '../widgets/quest_row.dart';
import '../widgets/stat_card.dart';
import 'goal_editor_sheet.dart';
import 'quest_editor_sheet.dart';

class GoalDetailSheet extends ConsumerWidget {
  final GoalData goal;
  final List<QuestEvaluation> quests;
  final double completionRate;

  const GoalDetailSheet({
    super.key,
    required this.goal,
    required this.quests,
    required this.completionRate,
  });

  static Future<void> show(
    BuildContext context, {
    required GoalData goal,
    required List<QuestEvaluation> quests,
    required double completionRate,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => GoalDetailSheet(
        goal: goal,
        quests: quests,
        completionRate: completionRate,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final int doneCount = quests.where((q) => q.isCompleted).length;
    final isAllCompleted = quests.isNotEmpty && doneCount == quests.length;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 32),
      decoration: BoxDecoration(
        color: tokens.bg,
        border: Border(
          top: BorderSide(color: tokens.lineRest, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              color: tokens.lineRule,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    goal.emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    goal.title,
                    style: tokens.headline(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: tokens.textPrimary,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Symbols.edit),
                onPressed: () {
                  Navigator.of(context).pop();
                  GoalEditorSheet.show(context, goal: goal);
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Hero Ring & Stat Cards
          Row(
            children: [
              CompletionRing(
                progress: completionRate,
                size: 72,
                strokeWidth: 4,
                child: Text(
                  '${(completionRate * 100).toInt()}%',
                  style: tokens.monoText(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: completionRate >= 1.0 ? tokens.hero : tokens.accent,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        value: '$doneCount/${quests.length}',
                        label: 'COMPLETED',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: StatCard(
                        value: '${quests.length}',
                        label: 'QUESTS',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Quests header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ASSIGNED QUESTS',
                style: tokens.monoText(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: tokens.textSecondary,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  QuestEditorSheet.show(context);
                },
                child: Text(
                  '+ ADD QUEST',
                  style: tokens.monoText(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: tokens.accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // List of quests
          Expanded(
            child: ListView.separated(
              itemCount: quests.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (ctx, i) {
                final q = quests[i];
                return QuestRow(
                  evaluation: q,
                  onComplete: () async {
                    final today = ref.read(effectiveLocalDateProvider);
                    final weekStart = ref.read(weekStartProvider);
                    final questData = await ref.read(questsDaoProvider).getQuestById(q.questId);
                    if (questData != null) {
                      await ref.read(questActionsProvider).completeQuest(
                            quest: questData,
                            date: today,
                            weekStart: weekStart,
                            now: DateTime.now(),
                          );
                    }
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Goal completion action
          ActionButton(
            label: 'COMPLETE GOAL (+250 XP)',
            variant: isAllCompleted ? ActionButtonVariant.primary : ActionButtonVariant.secondary,
            onPressed: () async {
              final today = ref.read(effectiveLocalDateProvider);
              final now = DateTime.now();
              await ref.read(goalActionsProvider).completeGoal(
                    id: goal.id,
                    today: today,
                    now: now,
                  );
              ref.read(activeCeremonyProvider.notifier).state = GoalCompletionCeremonyEvent(
                goalTitle: goal.title,
                xpEarned: 250,
              );
              if (context.mounted) Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
