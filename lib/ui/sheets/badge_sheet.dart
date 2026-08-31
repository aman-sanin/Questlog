import 'package:flutter/material.dart';
import '../../domain/engine/badges.dart';
import '../theme/tokens.dart';
import '../widgets/action_button.dart';

class BadgeSheet extends StatelessWidget {
  final BadgeStatus badge;

  const BadgeSheet({super.key, required this.badge});

  static Future<void> show(BuildContext context, {required BadgeStatus badge}) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BadgeSheet(badge: badge),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final def = badge.definition;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: tokens.bg,
        border: Border(
          top: BorderSide(color: tokens.lineRest, width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 4,
            color: tokens.lineRule,
          ),
          const SizedBox(height: 24),
          // Large Badge Icon
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: tokens.tonal,
              border: Border.all(
                color: badge.isEarned ? tokens.hero : tokens.lineRule,
                width: 1.5,
              ),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.military_tech,
              size: 36,
              color: badge.isEarned ? tokens.hero : tokens.textSecondary.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            def.title,
            style: tokens.headline(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: tokens.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            badge.isEarned ? 'EARNED' : 'LOCKED',
            style: tokens.monoText(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
              color: badge.isEarned ? tokens.hero : tokens.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            def.flavor,
            textAlign: TextAlign.center,
            style: tokens.body(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: tokens.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: tokens.tonal,
              border: Border.all(color: tokens.lineRule, width: 1),
            ),
            child: Text(
              'REQUIREMENT: ${def.requirement}',
              textAlign: TextAlign.center,
              style: tokens.monoText(
                fontSize: 12,
                color: tokens.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ActionButton(
            label: 'DISMISS',
            variant: ActionButtonVariant.secondary,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
