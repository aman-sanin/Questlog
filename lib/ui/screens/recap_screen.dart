import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:share_plus/share_plus.dart';
import '../theme/tokens.dart';
import '../widgets/action_button.dart';
import '../widgets/burst_widget.dart';
import '../widgets/stat_card.dart';

class MonthlyRecapScreen extends ConsumerWidget {
  const MonthlyRecapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            // Gilt manuscript container
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: tokens.tonal,
                border: Border.all(color: tokens.hero, width: 1.5),
              ),
              child: Column(
                children: [
                  BurstWidget(
                    size: 100,
                    child: Icon(Symbols.auto_awesome, size: 36, color: tokens.hero, fill: 1.0),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'OCTOBER RECAP',
                    style: tokens.monoText(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                      color: tokens.hero,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'THE UNBROKEN SCROLL',
                    textAlign: TextAlign.center,
                    style: tokens.display(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: tokens.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You answered the call across 28 days this month with discipline.',
                    textAlign: TextAlign.center,
                    style: tokens.body(fontSize: 13, color: tokens.textSecondary),
                  ),
                  const SizedBox(height: 24),

                  // Recap Stats Grid
                  const Row(
                    children: [
                      Expanded(
                        child: StatCard(value: '92%', label: 'COMPLETION'),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: StatCard(value: '+1,450', label: 'XP EARNED'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    children: [
                      Expanded(
                        child: StatCard(value: '18', label: 'PERFECT DAYS'),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: StatCard(value: '1', label: 'FREEZE SAVED'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Domain affinity bar
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
                  ClipRRect(
                    borderRadius: BorderRadius.zero,
                    child: Row(
                      children: [
                        Expanded(flex: 50, child: Container(height: 8, color: tokens.hero)),
                        Expanded(flex: 25, child: Container(height: 8, color: tokens.accent)),
                        Expanded(
                          flex: 25,
                          child: Container(height: 8, color: tokens.textPrimary.withOpacity(0.2)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('WARRIOR 50%', style: tokens.monoText(fontSize: 10, color: tokens.hero)),
                      Text('SAGE 25%', style: tokens.monoText(fontSize: 10, color: tokens.accent)),
                      Text(
                        'OTHER 25%',
                        style: tokens.monoText(fontSize: 10, color: tokens.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Share Action Button
            ActionButton(
              label: 'SHARE RECAP MANUSCRIPT',
              onPressed: () {
                Share.share(
                  'QuestLog October Recap: 92% completion rate, 18 Perfect Days, +1,450 XP earned!',
                  subject: 'QuestLog Monthly Recap',
                );
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
