import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../app/providers/badges_provider.dart';
import '../../domain/engine/badges.dart';
import '../sheets/badge_sheet.dart';
import '../theme/tokens.dart';
import '../widgets/badge_tile.dart';

class BadgesScreen extends ConsumerWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final stateAsync = ref.watch(badgesStateProvider);

    return Scaffold(
      backgroundColor: tokens.bg,
      body: SafeArea(
        child: stateAsync.when(
          loading: () => Center(
            child: CircularProgressIndicator(color: tokens.accent),
          ),
          error: (err, stack) => Center(
            child: Text('Error: $err', style: tokens.monoText(color: tokens.miss)),
          ),
          data: (state) {
            return Column(
              children: [
                // Top App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Symbols.arrow_back),
                        color: tokens.textPrimary,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'BADGES',
                                  style: tokens.headline(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: tokens.textPrimary,
                                  ),
                                ),
                                Text(
                                  '${state.earnedCount}/${state.totalCount}',
                                  style: tokens.monoText(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: tokens.accent,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: LinearProgressIndicator(
                                value: state.overallProgressRatio,
                                minHeight: 3,
                                backgroundColor: tokens.lineRule,
                                valueColor: AlwaysStoppedAnimation<Color>(tokens.accent),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
                Divider(color: tokens.lineRest, height: 1),

                // Badge Categories List
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    children: [
                      _buildCategorySection(
                        context,
                        title: 'JOURNEY',
                        category: BadgeCategory.journey,
                        badges: state.groupedByCategory[BadgeCategory.journey] ?? [],
                        tokens: tokens,
                      ),
                      const SizedBox(height: 24),
                      _buildCategorySection(
                        context,
                        title: 'STREAKS',
                        category: BadgeCategory.streaks,
                        badges: state.groupedByCategory[BadgeCategory.streaks] ?? [],
                        tokens: tokens,
                      ),
                      const SizedBox(height: 24),
                      _buildCategorySection(
                        context,
                        title: 'PERFECTION',
                        category: BadgeCategory.perfection,
                        badges: state.groupedByCategory[BadgeCategory.perfection] ?? [],
                        tokens: tokens,
                      ),
                      const SizedBox(height: 24),
                      _buildCategorySection(
                        context,
                        title: 'GOALS',
                        category: BadgeCategory.goals,
                        badges: state.groupedByCategory[BadgeCategory.goals] ?? [],
                        tokens: tokens,
                      ),
                      const SizedBox(height: 24),
                      _buildCategorySection(
                        context,
                        title: 'ECONOMY',
                        category: BadgeCategory.economy,
                        badges: state.groupedByCategory[BadgeCategory.economy] ?? [],
                        tokens: tokens,
                      ),
                      const SizedBox(height: 24),
                      _buildCategorySection(
                        context,
                        title: 'RARITIES',
                        category: BadgeCategory.rarities,
                        badges: state.groupedByCategory[BadgeCategory.rarities] ?? [],
                        tokens: tokens,
                      ),
                      const SizedBox(height: 24),
                      _buildCategorySection(
                        context,
                        title: 'CALLING · THE 12 TRIALS',
                        category: BadgeCategory.calling,
                        badges: state.groupedByCategory[BadgeCategory.calling] ?? [],
                        tokens: tokens,
                      ),
                      const SizedBox(height: 24),
                      _buildCategorySection(
                        context,
                        title: 'SEALED · THE KEEPER',
                        category: BadgeCategory.sealed,
                        badges: state.groupedByCategory[BadgeCategory.sealed] ?? [],
                        tokens: tokens,
                      ),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategorySection(
    BuildContext context, {
    required String title,
    required BadgeCategory category,
    required List<BadgeStatus> badges,
    required AppTokens tokens,
  }) {
    if (badges.isEmpty) return const SizedBox.shrink();

    final earnedCount = badges.where((b) => b.isEarned).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: tokens.monoText(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0,
                color: tokens.textSecondary,
              ),
            ),
            Text(
              '$earnedCount/${badges.length}',
              style: tokens.monoText(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: earnedCount == badges.length ? tokens.hero : tokens.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.0,
          ),
          itemCount: badges.length,
          itemBuilder: (context, index) {
            final badge = badges[index];
            return BadgeTile(
              badge: badge,
              onTap: () => BadgeSheet.show(context, badge: badge),
            );
          },
        ),
      ],
    );
  }
}
