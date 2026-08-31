import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
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
        decoration: BoxDecoration(
          color: isEarned ? tokens.tonal : Colors.transparent,
          border: Border.all(
            color: isEarned ? tokens.hero : tokens.lineRule,
            width: isEarned ? 1.5 : 1.0,
          ),
        ),
        alignment: Alignment.center,
        child: isEarned
            ? Icon(
                _iconForBadge(badge.definition.key),
                size: 20,
                color: tokens.hero,
                fill: 1.0,
              )
            : Icon(
                Symbols.lock,
                size: 16,
                color: tokens.textSecondary.withOpacity(0.3),
              ),
      ),
    );
  }

  IconData _iconForBadge(String key) {
    switch (key) {
      case 'first_step':
        return Symbols.directions_walk;
      case 'streak_7':
        return Symbols.repeat;
      case 'streak_30':
        return Symbols.shield;
      case 'streak_100':
        return Symbols.workspace_premium;
      case 'streak_365':
        return Symbols.military_tech;
      case 'centurion':
        return Symbols.looks_one;
      case 'millennial':
        return Symbols.diamond;
      case 'perfect_ten':
        return Symbols.hotel_class;
      case 'polymath':
        return Symbols.all_inclusive;
      case 'goal_getter':
        return Symbols.flag;
      case 'early_bird':
        return Symbols.wb_sunny;
      case 'comeback':
        return Symbols.refresh;
      default:
        return Symbols.military_tech;
    }
  }
}
