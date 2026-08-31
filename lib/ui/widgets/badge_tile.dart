import 'package:flutter/material.dart';
import '../../domain/engine/badges.dart';
import '../theme/tokens.dart';

class BadgeTile extends StatelessWidget {
  final BadgeStatus badge;
  final VoidCallback? onTap;

  const BadgeTile({
    super.key,
    required this.badge,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final isEarned = badge.isEarned;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: tokens.tonal,
          border: Border.all(
            color: isEarned ? tokens.lineRest : tokens.lineRule,
            width: 1,
          ),
        ),
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              _resolveIconData(badge.definition.icon),
              size: 20,
              color: isEarned ? tokens.hero : tokens.textSecondary.withOpacity(0.35),
            ),
            if (!isEarned)
              Positioned(
                bottom: 2,
                right: 2,
                child: Icon(
                  Icons.lock,
                  size: 10,
                  color: tokens.textSecondary.withOpacity(0.5),
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _resolveIconData(String iconName) {
    switch (iconName) {
      case 'footprint':
        return Icons.directions_walk;
      case 'repeat':
        return Icons.repeat;
      case 'shield':
        return Icons.shield;
      case 'workspace_premium':
        return Icons.workspace_premium;
      case 'military_tech':
        return Icons.military_tech;
      case 'counter_1':
        return Icons.looks_one;
      case 'diamond':
        return Icons.diamond;
      case 'hotel_class':
        return Icons.hotel_class;
      case 'all_inclusive':
        return Icons.all_inclusive;
      case 'flag':
        return Icons.flag;
      case 'wb_sunny':
        return Icons.wb_sunny;
      case 'refresh':
        return Icons.refresh;
      default:
        return Icons.military_tech;
    }
  }
}
