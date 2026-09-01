import 'package:flutter/material.dart';
import '../../domain/engine/badges.dart';
import '../theme/tokens.dart';
import '../widgets/action_button.dart';
import '../widgets/burst_widget.dart';


class BadgeSheet extends StatelessWidget {
  final BadgeStatus badge;

  const BadgeSheet({super.key, required this.badge});

  static Future<void> show(BuildContext context, {required BadgeStatus badge}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BadgeSheet(badge: badge),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final b = badge.definition;
    final isEarned = badge.isEarned;
    final isSealedUnearned = b.sealed && !isEarned;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: tokens.bg,
        border: Border(
          top: BorderSide(color: tokens.lineRest, width: 1),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                color: tokens.lineRule,
              ),
            ),
          const SizedBox(height: 24),

          if (isSealedUnearned) ...[
            // Sealed dialog
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: tokens.tonal,
                border: Border.all(
                  color: tokens.lineRest,
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                '?',
                style: tokens.monoText(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: tokens.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'SEALED BADGE',
              style: tokens.headline(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: tokens.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '“Sealed by the Keeper. Keep questing.”',
              textAlign: TextAlign.center,
              style: tokens.body(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: tokens.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
          ] else ...[
            // Known or Earned Badge Hero
            BurstWidget(
              size: 100,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isEarned ? tokens.tonal : Colors.transparent,
                  border: Border.all(
                    color: isEarned ? tokens.hero : tokens.lineRule,
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(
                  b.icon,
                  size: 32,
                  color: isEarned ? tokens.hero : tokens.textSecondary.withOpacity(0.4),
                  fill: isEarned ? 1.0 : 0.0,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Badge Title & Category
            Text(
              b.title.toUpperCase(),
              style: tokens.headline(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: tokens.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  b.category.name.toUpperCase(),
                  style: tokens.monoText(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                    color: tokens.textSecondary,
                  ),
                ),
                Text(
                  ' · ',
                  style: tokens.monoText(color: tokens.lineRule),
                ),
                Text(
                  isEarned ? 'EARNED' : 'LOCKED',
                  style: tokens.monoText(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    color: isEarned ? tokens.hero : tokens.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Flavor text
            Text(
              '“${b.flavor}”',
              textAlign: TextAlign.center,
              style: tokens.body(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: tokens.textSecondary,
              ),
            ),
            const SizedBox(height: 16),

            // Requirement Container
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
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
                        'REQUIREMENT',
                        style: tokens.monoText(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: tokens.textSecondary,
                        ),
                      ),
                      if (b.domain != null)
                        Text(
                          '${b.domain!.name.toUpperCase()} ONLY',
                          style: tokens.monoText(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: badge.isEligible ? tokens.accent : tokens.miss,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    b.requirement,
                    style: tokens.body(
                      fontSize: 13,
                      color: tokens.textPrimary,
                    ),
                  ),

                  // Progress Bar where honest
                  if (b.progressKind != ProgressKind.event && b.targetValue > 1) ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          b.progressKind == ProgressKind.peak ? 'PEAK PROGRESS' : 'PROGRESS',
                          style: tokens.monoText(
                            fontSize: 10,
                            color: tokens.textSecondary,
                          ),
                        ),
                        Text(
                          '${badge.currentValue.clamp(0, b.targetValue)} / ${b.targetValue}',
                          style: tokens.monoText(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isEarned ? tokens.hero : tokens.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: badge.progressRatio,
                        minHeight: 4,
                        backgroundColor: tokens.lineRule,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isEarned ? tokens.hero : tokens.accent,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Dismiss button
          ActionButton(
            label: 'DISMISS',
            variant: ActionButtonVariant.secondary,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    ),
  );
}
}

