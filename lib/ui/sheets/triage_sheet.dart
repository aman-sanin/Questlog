import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../app/providers/database_provider.dart';
import '../../app/providers/profile_provider.dart';
import '../../data/db/database.dart';
import '../../domain/engine/coach.dart';
import '../../domain/model/models.dart';
import '../theme/tokens.dart';

class TriageSheet extends ConsumerWidget {
  final List<String> questIds;

  const TriageSheet({
    super.key,
    required this.questIds,
  });

  static Future<void> show(BuildContext context, {required List<String> questIds}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => TriageSheet(questIds: questIds),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final questsDao = ref.watch(questsDaoProvider);
    final completionsDao = ref.watch(completionsDaoProvider);
    final today = ref.watch(effectiveLocalDateProvider);
    final weekStart = ref.watch(weekStartProvider);

    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        questsDao.getAllQuests(),
        completionsDao.getAllCompletions(),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            height: 250,
            color: tokens.tonal,
            alignment: Alignment.center,
            child: CircularProgressIndicator(color: tokens.accent),
          );
        }

        final allQuests = snapshot.data![0] as List<QuestData>;
        final allCompletions = snapshot.data![1] as List<CompletionData>;

        final completionsByQuest = <String, Map<LocalDate, int>>{};
        for (final c in allCompletions) {
          final d = LocalDate.parse(c.localDate);
          completionsByQuest.putIfAbsent(c.questId, () => {})[d] = (completionsByQuest[c.questId]?[d] ?? 0) + c.value;
        }

        final targetedQuests = allQuests.where((q) {
          if (questIds.isNotEmpty) {
            return questIds.contains(q.id) && q.archivedAt == null;
          }
          return q.archivedAt == null;
        }).toList();

        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 32),
          decoration: BoxDecoration(
            color: tokens.tonal,
            border: Border(
              top: BorderSide(color: tokens.lineRule, width: 1.5),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'LOAD TRIAGE',
                    style: tokens.headline(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: tokens.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Symbols.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Review underperforming quests to protect your momentum.',
                style: tokens.body(
                  fontSize: 13,
                  color: tokens.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: targetedQuests.length,
                  separatorBuilder: (_, __) => Divider(color: tokens.lineRest, height: 1),
                  itemBuilder: (context, idx) {
                    final q = targetedQuests[idx];
                    final questComps = completionsByQuest[q.id] ?? {};
                    
                    final historyData = QuestHistoryData(
                      id: q.id,
                      title: q.title,
                      rule: q.rule,
                      targetType: TargetType.values[q.targetType],
                      targetValue: q.targetValue,
                      difficulty: Difficulty.values[q.difficulty],
                      essential: q.essential,
                      createdAt: q.createdAt,
                      archivedAt: q.archivedAt,
                      pausedUntil: q.pausedUntil != null ? LocalDate.parse(q.pausedUntil!) : null,
                      completions: questComps,
                      currentStreak: 0,
                      isSatisfiedToday: false,
                    );

                    final stats = CoachEngine.calculate14dRate(
                      quest: historyData,
                      today: today,
                      weekStart: weekStart,
                    );
                    final ratePct = (stats.rate * 100).round();

                    final isPaused = q.pausedUntil != null && LocalDate.parse(q.pausedUntil!) >= today;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  q.title,
                                  style: tokens.title(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: tokens.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '14D RATE: $ratePct%',
                                  style: tokens.monoText(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: tokens.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (!isPaused)
                            GestureDetector(
                              onTap: () async {
                                final resumeDate = today.addDays(14);
                                await ref.read(questActionsProvider).pauseQuest(q.id, resumeDate);
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  border: Border.all(color: tokens.lineRule),
                                ),
                                child: Text(
                                  'PAUSE 14D',
                                  style: tokens.monoText(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: tokens.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () async {
                              await ref.read(questActionsProvider).archiveQuest(q.id, today.toDateTime());
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                border: Border.all(color: tokens.miss.withOpacity(0.5)),
                              ),
                              child: Text(
                                'ARCHIVE',
                                style: tokens.monoText(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: tokens.miss,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
