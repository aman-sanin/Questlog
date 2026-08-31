import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../app/providers/database_provider.dart';
import '../../app/providers/profile_provider.dart';
import '../../data/db/database.dart';
import '../../domain/engine/quest_state.dart';
import '../../domain/model/models.dart';
import '../theme/tokens.dart';
import '../widgets/action_button.dart';
import '../widgets/chips.dart';
import '../widgets/sigil_widget.dart';
import '../widgets/stat_card.dart';
import 'quest_editor_sheet.dart';

class QuestDetailSheet extends ConsumerWidget {
  final QuestData quest;
  final QuestEvaluation? evaluation;

  const QuestDetailSheet({
    super.key,
    required this.quest,
    this.evaluation,
  });

  static Future<void> show(
    BuildContext context, {
    required QuestData quest,
    QuestEvaluation? evaluation,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => QuestDetailSheet(
        quest: quest,
        evaluation: evaluation,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final completionsDao = ref.watch(completionsDaoProvider);
    final today = ref.watch(effectiveLocalDateProvider);

    final domain = quest.domain != null ? CallingDomain.values[quest.domain!] : CallingDomain.warrior;
    final diff = Difficulty.values[quest.difficulty];

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
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
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              color: tokens.lineRule,
            ),
          ),
          const SizedBox(height: 16),

          // Header Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: tokens.tonal,
                  border: Border.all(color: tokens.accent, width: 1.5),
                ),
                alignment: Alignment.center,
                child: SigilWidget(domain: domain, size: 24, color: tokens.accent),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            quest.title,
                            style: tokens.headline(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: tokens.textPrimary,
                            ),
                          ),
                        ),
                        if (quest.essential)
                          const EssentialStar(isEssential: true),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${quest.rule.cadence.name.toUpperCase()} · ${diff.name.toUpperCase()} · ${domain.name.toUpperCase()}',
                      style: tokens.monoText(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        color: tokens.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Stats Section
          FutureBuilder<List<dynamic>>(
            future: Future.wait([
              completionsDao.getCompletionsForQuest(quest.id),
              ref.read(ledgerDaoProvider).getAllXpEvents(),
            ]),
            builder: (context, snapshot) {
              final completions = (snapshot.data?[0] as List<CompletionData>?) ?? [];
              final xpEvents = (snapshot.data?[1] as List<XpEventData>?) ?? [];

              int totalQuestXp = 0;
              for (final e in xpEvents) {
                if (e.periodRef != null && e.periodRef!.startsWith('${quest.id}|')) {
                  totalQuestXp += e.amount;
                }
              }

              final streak = evaluation?.streak ?? 0;

              return Row(
                children: [
                  Expanded(
                    child: StatCard(
                      value: '$streak',
                      label: 'CURRENT STREAK',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StatCard(
                      value: '${completions.length}',
                      label: 'COMPLETIONS',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StatCard(
                      value: '$totalQuestXp',
                      label: 'TOTAL XP',
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),

          // 5-Week Mini Heatmap
          Text(
            'PAST 5 WEEKS',
            style: tokens.monoText(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
              color: tokens.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          FutureBuilder<List<CompletionData>>(
            future: completionsDao.getCompletionsInDateRange(
              today.subtractDays(34).formatted,
              today.formatted,
            ),
            builder: (context, snapshot) {
              final completions = snapshot.data?.where((c) => c.questId == quest.id).toList() ?? [];
              final completionMap = <LocalDate, int>{};
              for (final c in completions) {
                final d = LocalDate.parse(c.localDate);
                completionMap[d] = (completionMap[d] ?? 0) + c.value;
              }

              final days = List.generate(35, (i) {
                return today.subtractDays(34 - i);
              });

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: tokens.tonal,
                  border: Border.all(color: tokens.lineRest, width: 1),
                ),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: 35,
                  itemBuilder: (context, index) {
                    final d = days[index];
                    final isScheduled = quest.rule.isScheduledOn(d);
                    final count = completionMap[d] ?? 0;
                    final isDone = count >= quest.targetValue;
                    final isToday = d == today;

                    Color dotColor = tokens.textPrimary.withOpacity(0.06);
                    Border? dotBorder;

                    if (count > 0) {
                      dotColor = isDone ? tokens.accent : tokens.accent.withOpacity(0.40);
                    } else if (isScheduled && d < today) {
                      dotColor = quest.essential ? tokens.miss : tokens.textPrimary.withOpacity(0.12);
                    }

                    if (isToday) {
                      dotBorder = Border.all(color: tokens.accent, width: 1.5);
                    }

                    return Container(
                      decoration: BoxDecoration(
                        color: dotColor,
                        border: dotBorder,
                      ),
                    );
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          // Recent Activity Header
          Text(
            'RECENT COMPLETIONS',
            style: tokens.monoText(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
              color: tokens.textSecondary,
            ),
          ),
          const SizedBox(height: 8),

          // Recent Completions List
          Expanded(
            child: FutureBuilder<List<CompletionData>>(
              future: completionsDao.getCompletionsForQuest(quest.id),
              builder: (context, snapshot) {
                final completions = snapshot.data ?? [];
                if (completions.isEmpty) {
                  return Center(
                    child: Text(
                      'No completions logged yet.',
                      style: tokens.body(fontSize: 13, color: tokens.textSecondary),
                    ),
                  );
                }

                final reversed = completions.reversed.take(10).toList();

                return ListView.separated(
                  itemCount: reversed.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                  itemBuilder: (context, i) {
                    final c = reversed[i];
                    final date = LocalDate.parse(c.localDate);

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: tokens.tonal,
                        border: Border.all(color: tokens.lineRule, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Symbols.check_circle, size: 16, color: tokens.accent),
                                  const SizedBox(width: 8),
                                  Text(
                                    date.formatted,
                                    style: tokens.monoText(fontSize: 12, color: tokens.textPrimary),
                                  ),
                                ],
                              ),
                              Text(
                                '+${c.value} ${quest.unit ?? (c.value == 1 ? "time" : "times")}',
                                style: tokens.monoText(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: tokens.accent,
                                ),
                              ),
                            ],
                          ),
                          if (c.note != null && c.note!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              c.note!,
                              style: tokens.body(fontSize: 12, color: tokens.textSecondary),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ActionButton(
                  label: 'EDIT QUEST',
                  variant: ActionButtonVariant.primary,
                  onPressed: () {
                    Navigator.of(context).pop();
                    QuestEditorSheet.show(context, quest: quest);
                  },
                ),
              ),
              const SizedBox(width: 10),
              ActionButton(
                label: 'PAUSE',
                variant: ActionButtonVariant.secondary,
                isFullWidth: false,
                onPressed: () => _handlePause(context, ref, quest, today),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handlePause(BuildContext context, WidgetRef ref, QuestData q, LocalDate today) async {
    final tokens = context.tokens;
    final pauseUntil = await showDialog<LocalDate>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: tokens.bg,
        title: Text('PAUSE QUEST', style: tokens.headline(fontSize: 18, color: tokens.textPrimary)),
        content: Text('Pause streak evaluation for 7 days?', style: tokens.body(fontSize: 14, color: tokens.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: Text('CANCEL', style: tokens.monoText(color: tokens.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(today.addDays(7)),
            child: Text('PAUSE 7 DAYS', style: tokens.monoText(color: tokens.accent)),
          ),
        ],
      ),
    );

    if (pauseUntil != null) {
      await ref.read(questActionsProvider).pauseQuest(q.id, pauseUntil);
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Paused ${q.title} until ${pauseUntil.formatted}')),
        );
      }
    }
  }
}
