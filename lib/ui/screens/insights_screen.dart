import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../app/providers/insights_provider.dart';
import '../../app/providers/profile_provider.dart';
import '../../app/providers/today_provider.dart';
import '../../domain/model/models.dart';
import '../sheets/day_sheet.dart';
import '../theme/tokens.dart';
import '../widgets/chips.dart';
import '../widgets/heatmap_grid.dart';
import '../widgets/quest_row.dart';
import '../widgets/segmented_control.dart';
import '../widgets/year_heatmap_grid.dart';

final _insightsViewModeProvider = StateProvider.autoDispose<int>((ref) => 0);

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final insightsAsync = ref.watch(insightsStateProvider);
    final walletAsync = ref.watch(freezeWalletProvider);
    final selectedMonth = ref.watch(selectedInsightsMonthProvider);
    final weekStart = ref.watch(weekStartProvider);

    final String monthTitle = DateFormat('MMMM yyyy').format(selectedMonth.toDateTime()).toUpperCase();

    return Scaffold(
      backgroundColor: tokens.bg,
      body: SafeArea(
        child: insightsAsync.when(
          loading: () => Center(
            child: CircularProgressIndicator(color: tokens.accent),
          ),
          error: (err, stack) => Center(
            child: Text('Error: $err', style: tokens.monoText(color: tokens.miss)),
          ),
          data: (state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'INSIGHTS',
                        style: tokens.headline(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: tokens.textPrimary,
                        ),
                      ),
                      FreezeChip(count: walletAsync.value ?? 0),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Month / Year View Toggle
                  SegmentedControl<int>(
                    items: const [
                      SegmentItem(value: 0, label: 'Month View'),
                      SegmentItem(value: 1, label: 'Year (52 Weeks)'),
                    ],
                    selectedValue: ref.watch(_insightsViewModeProvider),
                    onSelected: (mode) => ref.read(_insightsViewModeProvider.notifier).state = mode,
                  ),
                  const SizedBox(height: 16),

                  if (ref.watch(_insightsViewModeProvider) == 0) ...[
                    // Month Navigation Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Symbols.chevron_left),
                          onPressed: () {
                            final prev = selectedMonth.month == 1
                                ? LocalDate(selectedMonth.year - 1, 12, 1)
                                : LocalDate(selectedMonth.year, selectedMonth.month - 1, 1);
                            ref.read(selectedInsightsMonthProvider.notifier).state = prev;
                          },
                        ),
                        Text(
                          monthTitle,
                          style: tokens.monoText(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: tokens.textPrimary,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Symbols.chevron_right),
                          onPressed: () {
                            final next = selectedMonth.month == 12
                                ? LocalDate(selectedMonth.year + 1, 1, 1)
                                : LocalDate(selectedMonth.year, selectedMonth.month + 1, 1);
                            ref.read(selectedInsightsMonthProvider.notifier).state = next;
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Month Heatmap
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: tokens.tonal,
                        border: Border.all(color: tokens.lineRest, width: 1),
                      ),
                      child: HeatmapGrid(
                        days: state.heatmapDays,
                        weekStart: weekStart,
                        onDaySelected: (day) => DaySheet.show(context, date: day),
                      ),
                    ),
                  ] else ...[
                    // Year Heatmap
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: tokens.tonal,
                        border: Border.all(color: tokens.lineRest, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'PAST 52 WEEKS',
                                style: tokens.monoText(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.0,
                                  color: tokens.textSecondary,
                                ),
                              ),
                              Text(
                                '${state.yearHeatmapDays.length} DAYS RECORDED',
                                style: tokens.monoText(
                                  fontSize: 10,
                                  color: tokens.accent,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          YearHeatmapGrid(
                            days: state.yearHeatmapDays,
                            weekStart: weekStart,
                            onDaySelected: (day) => DaySheet.show(context, date: day),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),

                  // The Path Teaser Card
                  InkWell(
                    onTap: () => context.push('/path'),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: tokens.tonal,
                        border: Border.all(color: tokens.accent, width: 1.5),
                      ),
                      child: Row(
                        children: [
                          Icon(Symbols.account_tree, size: 22, color: tokens.accent),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'THE PATH · PROGRESSION TREE',
                                  style: tokens.headline(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: tokens.accent,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Explore the 6 calling branches, radial mini-map, and trial mastery.',
                                  style: tokens.body(fontSize: 12, color: tokens.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          Icon(Symbols.arrow_forward, size: 16, color: tokens.accent),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Monthly Recap Teaser Card
                  InkWell(
                    onTap: () => context.push('/recap'),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: tokens.hero.withOpacity(0.08),
                        border: Border.all(color: tokens.hero, width: 1),
                      ),
                      child: Row(
                        children: [
                          Icon(Symbols.auto_awesome, size: 20, color: tokens.hero, fill: 1.0),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'MONTHLY RECAP AVAILABLE',
                                  style: tokens.title(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: tokens.hero,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Review your achievements and share your illuminated manuscript.',
                                  style: tokens.body(fontSize: 12, color: tokens.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          Icon(Symbols.arrow_forward, size: 16, color: tokens.hero),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Rotating Weekly Insight Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: tokens.tonal,
                      border: Border.all(color: tokens.lineRest, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.weeklyInsight.headline,
                          style: tokens.monoText(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.0,
                            color: tokens.accent,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          state.weeklyInsight.stat,
                          style: tokens.title(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: tokens.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          state.weeklyInsight.detail,
                          style: tokens.body(
                            fontSize: 13,
                            color: tokens.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Streaks Leaderboard
                  Text(
                    'ACTIVE STREAKS',
                    style: tokens.monoText(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.0,
                      color: tokens.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  for (final q in state.streakLeaderboard)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: QuestRow(evaluation: q),
                    ),

                  const SizedBox(height: 80),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
