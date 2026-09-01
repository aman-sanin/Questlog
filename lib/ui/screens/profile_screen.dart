import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../app/providers/profile_view_provider.dart';
import '../../domain/model/models.dart';
import '../ceremonies/ceremonies.dart';
import '../sheets/badge_sheet.dart';
import '../theme/tokens.dart';
import '../widgets/action_button.dart';
import '../widgets/badge_tile.dart';
import '../widgets/progress_bar.dart';
import '../widgets/sigil_widget.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final stateAsync = ref.watch(profileViewStateProvider);

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
            final prog = state.progression;
            final chosenDomain = state.profile.calling != null
                ? CallingDomain.values[state.profile.calling!]
                : null;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Top Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'PROFILE',
                        style: tokens.headline(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: tokens.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Symbols.settings),
                        onPressed: () => context.push('/settings'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Crest Sigil Hero Container
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: tokens.tonal,
                      border: Border.all(color: tokens.accent, width: 1.5),
                    ),
                    alignment: Alignment.center,
                    child: SigilWidget(
                      domain: chosenDomain ?? CallingDomain.warrior,
                      size: 40,
                      color: tokens.accent,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (state.profile.name != null && state.profile.name!.trim().isNotEmpty) ...[
                    Text(
                      state.profile.name!.trim().toUpperCase(),
                      style: tokens.monoText(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        color: tokens.accent,
                      ),
                    ),
                    const SizedBox(height: 2),
                  ],
                  Text(
                    prog.title.toUpperCase(),
                    style: tokens.display(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: tokens.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${chosenDomain != null ? chosenDomain.name.toUpperCase() : "NO CALLING"} · LEVEL ${prog.level} · ${prog.totalXp} XP',
                    style: tokens.monoText(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.0,
                      color: tokens.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // XP Progress Track
                  ProgressBar(
                    progress: prog.levelProgress,
                    height: 4.0,
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${prog.xpToNextLevel} XP TO LEVEL ${prog.level + 1}',
                      style: tokens.monoText(
                        fontSize: 11,
                        color: tokens.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Calling Action / Respec Button
                  ActionButton(
                    label: chosenDomain == null ? 'CHOOSE CALLING' : 'CHANGE CALLING',
                    variant: ActionButtonVariant.secondary,
                    onPressed: () => CallingSelectionSheet.show(context),
                  ),
                  const SizedBox(height: 28),

                  // Lifetime Records Section
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'LIFETIME RECORDS',
                      style: tokens.monoText(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                        color: tokens.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: tokens.tonal,
                            border: Border.all(color: tokens.lineRest, width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${state.records.maxDayXp} XP',
                                style: tokens.monoText(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: tokens.accent,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'BEST DAY XP',
                                style: tokens.monoText(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: tokens.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: tokens.tonal,
                            border: Border.all(color: tokens.lineRest, width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${state.records.bestStreak} DAYS',
                                style: tokens.monoText(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: tokens.accent,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'LONGEST STREAK',
                                style: tokens.monoText(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: tokens.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: tokens.tonal,
                            border: Border.all(color: tokens.lineRest, width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${state.records.bestWeekXp} XP',
                                style: tokens.monoText(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: tokens.accent,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'BEST 7-DAY WINDOW',
                                style: tokens.monoText(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: tokens.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: tokens.tonal,
                            border: Border.all(color: tokens.lineRest, width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${state.records.freezesUsed}',
                                style: tokens.monoText(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: tokens.accent,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'FREEZES USED',
                                style: tokens.monoText(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: tokens.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Badges Grid Section (Clickable to /badges)
                  InkWell(
                    onTap: () => context.push('/badges'),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'BADGES · ${state.badges.where((b) => b.isEarned).length}/${state.badges.length}',
                            style: tokens.monoText(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.0,
                              color: tokens.textSecondary,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                'VIEW ALL',
                                style: tokens.monoText(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: tokens.accent,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(Symbols.arrow_forward, size: 14, color: tokens.accent),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: state.badges.length > 12 ? 12 : state.badges.length,
                    itemBuilder: (context, index) {
                      final badge = state.badges[index];
                      return BadgeTile(
                        badge: badge,
                        onTap: () => BadgeSheet.show(context, badge: badge),
                      );
                    },
                  ),
                  const SizedBox(height: 32),

                  // Unlock Ladder Track
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'UNLOCK TRACK',
                      style: tokens.monoText(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                        color: tokens.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (final item in state.unlockItems) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: item.level <= prog.level ? tokens.tonal : Colors.transparent,
                        border: Border.all(
                          color: item.level <= prog.level ? tokens.lineRest : tokens.lineRule,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: tokens.bg,
                              border: Border.all(
                                color: item.level <= prog.level ? tokens.accent : tokens.lineRule,
                                width: 1,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'L${item.level}',
                              style: tokens.monoText(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: item.level <= prog.level ? tokens.accent : tokens.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: tokens.title(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: item.level <= prog.level
                                        ? tokens.textPrimary
                                        : tokens.textSecondary.withOpacity(0.5),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item.description,
                                  style: tokens.body(
                                    fontSize: 12,
                                    color: tokens.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            item.level <= prog.level ? Symbols.check : Symbols.lock,
                            size: 16,
                            color: item.level <= prog.level ? tokens.hero : tokens.textSecondary.withOpacity(0.4),
                          ),
                        ],
                      ),
                    ),
                  ],

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
