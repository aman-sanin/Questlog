import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:share_plus/share_plus.dart';
import '../../app/providers/recap_provider.dart';
import '../../domain/engine/insights.dart';
import '../../domain/model/models.dart';
import '../theme/tokens.dart';
import '../widgets/action_button.dart';
import '../widgets/burst_widget.dart';
import '../widgets/stat_card.dart';

class MonthlyRecapScreen extends ConsumerWidget {
  const MonthlyRecapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final recapAsync = ref.watch(monthlyRecapProvider);

    return Scaffold(
      backgroundColor: tokens.bg,
      appBar: AppBar(
        backgroundColor: tokens.bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Symbols.close),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/insights');
            }
          },
        ),
        title: Text(
          'MONTHLY RECAP',
          style: tokens.monoText(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: tokens.textPrimary,
          ),
        ),
      ),
      body: recapAsync.when(
        loading: () =>
            Center(child: CircularProgressIndicator(color: tokens.accent)),
        error: (err, _) => Center(
          child: Text(
            'Error: $err',
            style: tokens.monoText(color: tokens.miss),
          ),
        ),
        data: (recap) => SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              _Manuscript(recap: recap, tokens: tokens),
              const SizedBox(height: 24),
              ActionButton(
                label: 'SHARE RECAP MANUSCRIPT',
                onPressed: () {
                  Share.share(
                    _shareText(recap),
                    subject: 'QuestLog Monthly Recap',
                  );
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

String _monthTitle(MonthlyRecapData recap) => DateFormat(
  'MMMM yyyy',
).format(DateTime(recap.year, recap.month)).toUpperCase();

String _prevMonthTitle(MonthlyRecapData recap) {
  final prev = recap.month == 1
      ? DateTime(recap.year - 1, 12)
      : DateTime(recap.year, recap.month - 1);
  return DateFormat('MMMM').format(prev).toUpperCase();
}

String _pct(double rate) => '${(rate * 100).round()}%';

String _signedPts(double trend) {
  final pts = trend * 100;
  final sign = pts >= 0 ? '+' : '−';
  return '$sign${pts.abs().toStringAsFixed(1)} PTS';
}

String _xp(int amount) {
  final digits = amount.toString();
  final buf = StringBuffer('+');
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buf.write(',');
    buf.write(digits[i]);
  }
  return buf.toString();
}

String _shareText(MonthlyRecapData recap) {
  final month = DateFormat('MMMM').format(DateTime(recap.year, recap.month));
  return 'QuestLog $month Recap: ${_pct(recap.completionRate)} completion rate, '
      '${recap.perfectDaysCount} Perfect Days, ${_xp(recap.totalXpEarned)} XP earned!';
}

class _Manuscript extends StatelessWidget {
  final MonthlyRecapData recap;
  final AppTokens tokens;

  const _Manuscript({required this.recap, required this.tokens});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: tokens.tonal,
        border: Border.all(color: tokens.hero, width: 1.5),
      ),
      child: Column(
        children: [
          BurstWidget(
            size: 100,
            child: Icon(
              Symbols.auto_awesome,
              size: 36,
              color: tokens.hero,
              fill: 1.0,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${_monthTitle(recap)} RECAP',
            style: tokens.monoText(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
              color: tokens.hero,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _monthTitle(recap),
            textAlign: TextAlign.center,
            style: tokens.display(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: tokens.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            recap.totalCompletions > 0
                ? 'You answered the call across ${recap.activeDays} days '
                      'with ${_pct(recap.completionRate)} completion.'
                : 'Nothing logged this month — a blank page, honestly kept.',
            textAlign: TextAlign.center,
            style: tokens.body(fontSize: 13, color: tokens.textSecondary),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  value: _pct(recap.completionRate),
                  label: 'COMPLETION',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatCard(
                  value: _xp(recap.totalXpEarned),
                  label: 'XP EARNED',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  value: '${recap.perfectDaysCount}',
                  label: 'PERFECT DAYS',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatCard(
                  value: '${recap.bestStreak}',
                  label: 'BEST STREAK',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  value: _signedPts(recap.completionTrendVsLastMonth),
                  label: 'TREND VS ${_prevMonthTitle(recap)}',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatCard(
                  value: '${recap.freezesSavedCount}',
                  label: 'FREEZES SAVED',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _AffinityBar(recap: recap, tokens: tokens),
          if (recap.mostCompletedQuestTitle != null) ...[
            const SizedBox(height: 16),
            _QuestOfMonth(recap: recap, tokens: tokens),
          ],
        ],
      ),
    );
  }
}

class _AffinityBar extends StatelessWidget {
  final MonthlyRecapData recap;
  final AppTokens tokens;

  const _AffinityBar({required this.recap, required this.tokens});

  @override
  Widget build(BuildContext context) {
    final entries = recap.domainAffinity.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'DOMAIN AFFINITY',
            style: tokens.monoText(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
              color: tokens.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (entries.isEmpty)
          Text(
            'No domain data yet.',
            style: tokens.body(fontSize: 12, color: tokens.textSecondary),
          )
        else ...[
          ClipRRect(
            borderRadius: BorderRadius.zero,
            child: Row(children: _segments(entries)),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _labels(entries),
          ),
        ],
      ],
    );
  }

  List<Widget> _segments(List<MapEntry<CallingDomain, double>> entries) {
    final top = entries.take(2).toList();
    final rest = entries.skip(2).fold(0.0, (s, e) => s + e.value);
    final colors = [tokens.hero, tokens.accent];
    final segs = <Widget>[];
    for (var i = 0; i < top.length; i++) {
      final flex = (top[i].value * 100).round().clamp(1, 100);
      segs.add(
        Expanded(
          flex: flex,
          child: Container(height: 8, color: colors[i]),
        ),
      );
    }
    if (rest > 0) {
      final flex = (rest * 100).round().clamp(1, 100);
      segs.add(
        Expanded(
          flex: flex,
          child: Container(
            height: 8,
            color: tokens.textPrimary.withOpacity(0.2),
          ),
        ),
      );
    }
    return segs;
  }

  List<Widget> _labels(List<MapEntry<CallingDomain, double>> entries) {
    final top = entries.take(2).toList();
    final rest = entries.skip(2).fold(0.0, (s, e) => s + e.value);
    final colors = [tokens.hero, tokens.accent];
    final labels = <Widget>[];
    for (var i = 0; i < top.length; i++) {
      labels.add(
        Text(
          '${top[i].key.name.toUpperCase()} ${(top[i].value * 100).round()}%',
          style: tokens.monoText(fontSize: 10, color: colors[i]),
        ),
      );
    }
    if (rest > 0) {
      labels.add(
        Text(
          'OTHER ${(rest * 100).round()}%',
          style: tokens.monoText(fontSize: 10, color: tokens.textSecondary),
        ),
      );
    }
    return labels;
  }
}

class _QuestOfMonth extends StatelessWidget {
  final MonthlyRecapData recap;
  final AppTokens tokens;

  const _QuestOfMonth({required this.recap, required this.tokens});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tokens.bg,
        border: Border.all(color: tokens.lineRest, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'QUEST OF THE MONTH',
            style: tokens.monoText(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
              color: tokens.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            recap.mostCompletedQuestTitle ?? '—',
            style: tokens.title(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: tokens.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${recap.mostCompletedQuestCount} completions',
            style: tokens.body(fontSize: 12, color: tokens.textSecondary),
          ),
        ],
      ),
    );
  }
}
