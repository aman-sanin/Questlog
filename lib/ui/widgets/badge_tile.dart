import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../domain/engine/badges.dart';
import '../theme/tokens.dart';

class BadgeTile extends StatelessWidget {
  final BadgeStatus badge;
  final VoidCallback? onTap;
  final double size;

  const BadgeTile({
    super.key,
    required this.badge,
    this.onTap,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final isEarned = badge.isEarned;
    final isSealedLocked = badge.definition.sealed && !isEarned;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isEarned ? tokens.tonal : Colors.transparent,
          border: Border.all(
            color: isEarned
                ? tokens.hero
                : (isSealedLocked ? tokens.lineRest : tokens.lineRule),
            width: isEarned ? 1.5 : 1.0,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (isSealedLocked)
              Text(
                '?',
                style: tokens.monoText(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: tokens.textSecondary.withOpacity(0.5),
                ),
              )
            else if (isEarned)
              Icon(
                badge.definition.icon,
                size: 22,
                color: tokens.hero,
                fill: 1.0,
              )
            else ...[
              // Locked but known
              Icon(
                badge.definition.icon,
                size: 20,
                color: tokens.textSecondary.withOpacity(0.35),
              ),
              Positioned(
                right: 3,
                bottom: 3,
                child: Icon(
                  Symbols.lock,
                  size: 10,
                  color: tokens.textSecondary.withOpacity(0.4),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

