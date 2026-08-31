import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../app/providers/database_provider.dart';
import '../../app/providers/profile_provider.dart';
import '../../app/providers/today_provider.dart';
import '../../data/db/database.dart';
import '../../domain/model/models.dart';
import '../theme/tokens.dart';
import '../widgets/action_button.dart';

/// Completions for a specific date (loaded once when sheet opens)
final _daySheetCompletionsProvider = FutureProvider.family<List<CompletionData>, String>((ref, dateStr) {
  return ref.watch(completionsDaoProvider).getCompletionsInDateRange(dateStr, dateStr);
});

class DaySheet extends ConsumerWidget {
  final LocalDate date;

  const DaySheet({super.key, required this.date});

  static Future<void> show(BuildContext context, {required LocalDate date}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DaySheet(date: date),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final today = ref.watch(effectiveLocalDateProvider);
    final weekStart = ref.watch(weekStartProvider);
    final questsAsync = ref.watch(activeQuestsStreamProvider);
    final completionsAsync = ref.watch(_daySheetCompletionsProvider(date.formatted));

    final quests = questsAsync.value ?? [];
    final completions = completionsAsync.value ?? [];

    final isBackfillAllowed = date <= today && date >= today.subtractDays(30);

    // Index completions by questId -> total value logged on this date
    final completedByQuest = <String, int>{};
    for (final c in completions) {
      completedByQuest[c.questId] = (completedByQuest[c.questId] ?? 0) + c.value;
    }

    // Filter: only quests that existed on this date AND were scheduled
    final scheduledQuests = quests.where((q) {
      final createdDate = LocalDate.fromDateTime(q.createdAt);
      if (date < createdDate) return false; // quest didn't exist yet
      return q.rule.isScheduledOn(date, weekStart.value);
    }).toList();

    // Quests that existed but were off-schedule (for context if backfilling)
    final offScheduleQuests = isBackfillAllowed
        ? quests.where((q) {
            final createdDate = LocalDate.fromDateTime(q.createdAt);
            if (date < createdDate) return false;
            return !q.rule.isScheduledOn(date, weekStart.value);
          }).toList()
        : <QuestData>[];

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.80,
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
          Text(
            'HISTORICAL LOG',
            style: tokens.monoText(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
              color: tokens.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            date.formatted,
            style: tokens.headline(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: tokens.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          // Summary line
          if (completionsAsync.hasValue)
            Text(
              scheduledQuests.isEmpty
                  ? 'No quests were active on this day'
                  : '${completedByQuest.keys.where((id) => scheduledQuests.any((q) => q.id == id)).length} / ${scheduledQuests.length} completed',
              style: tokens.monoText(fontSize: 11, color: tokens.textSecondary),
            ),
          const SizedBox(height: 16),
          if (!isBackfillAllowed)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'Backfill is restricted to the last 30 days.',
                style: tokens.monoText(fontSize: 12, color: tokens.miss),
              ),
            ),
          Expanded(
            child: completionsAsync.isLoading
                ? Center(child: CircularProgressIndicator(color: tokens.accent))
                : scheduledQuests.isEmpty && offScheduleQuests.isEmpty
                    ? Center(
                        child: Text(
                          'No quests were active on this day.',
                          style: tokens.body(fontSize: 14, color: tokens.textSecondary),
                        ),
                      )
                    : ListView(
                        children: [
                          // ── Scheduled quests ──────────────────────────────
                          if (scheduledQuests.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                'SCHEDULED',
                                style: tokens.monoText(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.0,
                                  color: tokens.accent,
                                ),
                              ),
                            ),
                            for (final q in scheduledQuests) ...[
                              _QuestDayTile(
                                q: q,
                                date: date,
                                loggedValue: completedByQuest[q.id] ?? 0,
                                isBackfillAllowed: isBackfillAllowed,
                                weekStart: weekStart,
                              ),
                              const SizedBox(height: 8),
                            ],
                          ],
                          // ── Off-schedule (backfill only) ──────────────────
                          if (offScheduleQuests.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                'OFF-SCHEDULE · BACKFILL ONLY',
                                style: tokens.monoText(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.0,
                                  color: tokens.textSecondary,
                                ),
                              ),
                            ),
                            for (final q in offScheduleQuests) ...[
                              _QuestDayTile(
                                q: q,
                                date: date,
                                loggedValue: completedByQuest[q.id] ?? 0,
                                isBackfillAllowed: isBackfillAllowed,
                                weekStart: weekStart,
                              ),
                              const SizedBox(height: 8),
                            ],
                          ],
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}

class _QuestDayTile extends ConsumerWidget {
  final QuestData q;
  final LocalDate date;
  final int loggedValue;
  final bool isBackfillAllowed;
  final WeekStart weekStart;

  const _QuestDayTile({
    required this.q,
    required this.date,
    required this.loggedValue,
    required this.isBackfillAllowed,
    required this.weekStart,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final target = q.targetValue;
    final isDone = loggedValue >= target;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: tokens.tonal,
        border: Border.all(
          color: isDone ? tokens.accent.withOpacity(0.5) : tokens.lineRest,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Completion indicator
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isDone ? tokens.accent.withOpacity(0.15) : Colors.transparent,
              border: Border.all(
                color: isDone ? tokens.accent : tokens.lineRule,
                width: 1.5,
              ),
            ),
            child: isDone
                ? Icon(Symbols.check, size: 14, color: tokens.accent)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  q.title,
                  style: tokens.title(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: tokens.textPrimary,
                  ),
                ),
                if (q.targetType == 1 && loggedValue > 0) ...[
                  const SizedBox(height: 2),
                  Text(
                    '$loggedValue / $target ${q.unit ?? ''}',
                    style: tokens.monoText(fontSize: 10, color: tokens.textSecondary),
                  ),
                ],
              ],
            ),
          ),
          if (isBackfillAllowed && !isDone)
            ActionButton(
              label: 'LOG',
              height: 32,
              isFullWidth: false,
              variant: ActionButtonVariant.secondary,
              onPressed: () async {
                await ref.read(questActionsProvider).completeQuest(
                      quest: q,
                      date: date,
                      weekStart: weekStart,
                      now: DateTime.now(),
                    );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Logged ${q.title} for ${date.formatted}')),
                  );
                }
              },
            ),
        ],
      ),
    );
  }
}

