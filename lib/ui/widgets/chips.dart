import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../domain/model/models.dart';
import '../theme/tokens.dart';

class CadenceChip extends StatelessWidget {
  final Cadence cadence;
  final bool isWindow;

  const CadenceChip({
    super.key,
    required this.cadence,
    this.isWindow = false,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final text = isWindow ? '${cadence.name.toUpperCase()} (FLEX)' : cadence.name.toUpperCase();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: tokens.tonal,
        border: Border.all(color: tokens.lineRule, width: 1),
      ),
      child: Text(
        text,
        style: tokens.monoText(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: tokens.textSecondary,
        ),
      ),
    );
  }
}

class LevelChip extends StatelessWidget {
  final int level;
  final VoidCallback? onTap;

  const LevelChip({
    super.key,
    required this.level,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: tokens.tonal,
          border: Border.all(color: tokens.lineRest, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: tokens.accent,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'L$level',
              style: tokens.monoText(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: tokens.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FreezeChip extends StatelessWidget {
  final int count;
  final int capacity;

  const FreezeChip({
    super.key,
    required this.count,
    this.capacity = 2,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: tokens.tonal,
        border: Border.all(
          color: count > 0 ? tokens.accent : tokens.lineRule,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Symbols.ac_unit,
            size: 13,
            color: count > 0 ? tokens.accent : tokens.textSecondary.withOpacity(0.4),
          ),
          const SizedBox(width: 4),
          Text(
            '$count/$capacity',
            style: tokens.monoText(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: count > 0 ? tokens.accent : tokens.textSecondary.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }
}

class EssentialStar extends StatelessWidget {
  final bool isEssential;
  final VoidCallback? onTap;

  const EssentialStar({
    super.key,
    required this.isEssential,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return GestureDetector(
      onTap: onTap,
      child: Icon(
        isEssential ? Symbols.star : Symbols.star_border,
        size: 16,
        color: isEssential ? tokens.hero : tokens.textSecondary.withOpacity(0.3),
        fill: isEssential ? 1.0 : 0.0,
      ),
    );
  }
}
