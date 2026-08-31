import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
          icon: const Icon(Icons.close),
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
                    child: Icon(Icons.auto_awesome, size: 36, color: tokens.hero),
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
                  const SizedBox(height: 4),
                  Text(
                    'The Illuminated Scroll',
                    style: tokens.display(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: tokens.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 2x2 Stat Cards
                  Row(
                    children: const [
                      Expanded(
                        child: StatCard(
                          value: '1,420',
                          label: 'TOTAL XP',
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: StatCard(
                          value: '18',
                          label: 'PERFECT DAYS',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: const [
                      Expanded(
                        child: StatCard(
                          value: '23',
                          label: 'BEST STREAK',
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: StatCard(
                          value: '94',
                          label: 'COMPLETIONS',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Most Completed Quest
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
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
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.0,
                            color: tokens.accent,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Morning Pushups & Core',
                          style: tokens.title(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: tokens.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '28 completions · 100% adherence',
                          style: tokens.monoText(
                            fontSize: 12,
                            color: tokens.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Share button
            ActionButton(
              label: 'SHARE RECAP',
              onPressed: () {
                Share.share(
                  '⚔️ QuestLog Monthly Recap: 1,420 XP earned, 18 Perfect Days, and a 23-day streak!',
                  subject: 'QuestLog Monthly Recap',
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
