import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/providers/database_provider.dart';
import '../../app/providers/profile_provider.dart';
import '../../app/providers/today_provider.dart';
import '../../domain/model/models.dart';
import '../theme/tokens.dart';
import '../widgets/action_button.dart';

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
    final quests = questsAsync.value ?? [];

    final isBackfillAllowed = date <= today && date >= today.subtractDays(30);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
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
            child: ListView.separated(
              itemCount: quests.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (ctx, i) {
                final q = quests[i];
                final isScheduled = q.rule.isScheduledOn(date);

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: tokens.tonal,
                    border: Border.all(color: tokens.lineRest, width: 1),
                  ),
                  child: Row(
                    children: [
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
                            const SizedBox(height: 2),
                            Text(
                              isScheduled ? 'SCHEDULED' : 'OFF-SCHEDULE',
                              style: tokens.monoText(
                                fontSize: 10,
                                color: isScheduled ? tokens.accent : tokens.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isBackfillAllowed)
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
              },
            ),
          ),
        ],
      ),
    );
  }
}
