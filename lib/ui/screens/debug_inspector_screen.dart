import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../app/providers/database_provider.dart';
import '../../app/providers/profile_provider.dart';
import '../../app/providers/today_provider.dart';
import '../../data/db/database.dart';
import '../../domain/constants/xp_constants.dart';
import '../../domain/model/models.dart';
import '../theme/tokens.dart';
import '../widgets/action_button.dart';
import '../widgets/stat_card.dart';

class DebugInspectorScreen extends ConsumerWidget {
  const DebugInspectorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final now = ref.watch(currentDateTimeProvider);
    final today = ref.watch(effectiveLocalDateProvider);
    final weekStart = ref.watch(weekStartProvider);
    final offset = ref.watch(debugClockOffsetProvider);
    final profileAsync = ref.watch(profileStreamProvider);
    final profile = profileAsync.value;
    final streakRepairsAsync = ref.watch(streakRepairsStreamProvider);
    final streakRepairs = streakRepairsAsync.value ?? [];

    final isOffsetActive = offset != Duration.zero;

    return Scaffold(
      backgroundColor: tokens.bg,
      appBar: AppBar(
        backgroundColor: tokens.bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Symbols.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'DEBUG CLOCK & INSPECTOR',
          style: tokens.monoText(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: tokens.hero,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Current Simulated Clock Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: tokens.tonal,
              border: Border.all(
                color: isOffsetActive ? tokens.hero : tokens.lineRest,
                width: isOffsetActive ? 1.5 : 1.0,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'SIMULATED CLOCK',
                      style: tokens.monoText(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                        color: isOffsetActive ? tokens.hero : tokens.textSecondary,
                      ),
                    ),
                    if (isOffsetActive)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        color: tokens.hero,
                        child: Text(
                          'OFFSET ACTIVE',
                          style: tokens.monoText(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: tokens.onSolid,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormat('EEEE, MMMM d, yyyy').format(now).toUpperCase(),
                  style: tokens.headline(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: tokens.textPrimary,
                  ),
                ),
                Text(
                  '${DateFormat('HH:mm:ss').format(now)} · Effective: ${today.formatted}',
                  style: tokens.monoText(
                    fontSize: 12,
                    color: tokens.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Clock Controls Grid
          Text(
            'TIME TRAVEL CONTROLS',
            style: tokens.monoText(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
              color: tokens.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ActionButton(
                  label: '+1 DAY',
                  height: 38,
                  variant: ActionButtonVariant.secondary,
                  onPressed: () {
                    ref.read(debugClockOffsetProvider.notifier).state +=
                        const Duration(days: 1);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ActionButton(
                  label: '+7 DAYS',
                  height: 38,
                  variant: ActionButtonVariant.secondary,
                  onPressed: () {
                    ref.read(debugClockOffsetProvider.notifier).state +=
                        const Duration(days: 7);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ActionButton(
                  label: '+30 DAYS',
                  height: 38,
                  variant: ActionButtonVariant.secondary,
                  onPressed: () {
                    ref.read(debugClockOffsetProvider.notifier).state +=
                        const Duration(days: 30);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ActionButton(
                  label: 'JUMP TO DATE',
                  height: 38,
                  variant: ActionButtonVariant.secondary,
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: now,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2035),
                    );
                    if (picked != null) {
                      final target = DateTime(
                        picked.year,
                        picked.month,
                        picked.day,
                        now.hour,
                        now.minute,
                      );
                      ref.read(debugClockOffsetProvider.notifier).state =
                          target.difference(DateTime.now());
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ActionButton(
                  label: 'RESET TO REAL TIME',
                  height: 38,
                  variant: ActionButtonVariant.destructive,
                  onPressed: () {
                    ref.read(debugClockOffsetProvider.notifier).state = Duration.zero;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Settlement Trigger Action
          ActionButton(
            label: 'FORCE SETTLEMENT CHECK',
            variant: ActionButtonVariant.primary,
            onPressed: () async {
              await ref.read(questActionsProvider).settle(
                    today: today,
                    weekStart: weekStart,
                    now: now,
                  );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settlement convergence completed.')),
                );
              }
            },
          ),
          const SizedBox(height: 24),

          // Data Inspector - State Variables
          Text(
            'DATA INSPECTOR (READ-ONLY)',
            style: tokens.monoText(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
              color: tokens.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  value: today.formatted,
                  label: 'EFFECTIVE TODAY',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatCard(
                  value: profile?.settledThrough ?? 'NONE',
                  label: 'PROFILE SETTLED',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  value: '${streakRepairs.length}/${XpConstants.freezeWalletCapacity}',
                  label: 'CONSUMED REPAIRS',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatCard(
                  value: weekStart.name.toUpperCase(),
                  label: 'WEEK START',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Recent Ledger Events Inspector
          Text(
            'RECENT LEDGER EVENTS (LAST 10)',
            style: tokens.monoText(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
              color: tokens.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          FutureBuilder<List<XpEventData>>(
            future: ref.read(ledgerDaoProvider).getAllXpEvents(),
            builder: (context, snapshot) {
              final events = snapshot.data ?? [];
              final recent = events.reversed.take(10).toList();

              if (recent.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  color: tokens.tonal,
                  child: Text(
                    'No ledger events recorded yet.',
                    style: tokens.monoText(fontSize: 12, color: tokens.textSecondary),
                  ),
                );
              }

              return Column(
                children: recent.map((e) {
                  final eventType = XpEventType.values[e.type];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: tokens.tonal,
                      border: Border.all(color: tokens.lineRule, width: 1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${eventType.name.toUpperCase()} · ${e.localDate}',
                              style: tokens.monoText(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: tokens.textPrimary,
                              ),
                            ),
                            Text(
                              'ref: ${e.ref}',
                              style: tokens.monoText(
                                fontSize: 10,
                                color: tokens.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '+${e.amount} XP',
                          style: tokens.monoText(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: tokens.hero,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
