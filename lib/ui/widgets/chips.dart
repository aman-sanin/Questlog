import 'package:flutter/material.dart';
import '../theme/tokens.dart';

class CadenceChip extends StatelessWidget {
  final String label;
  final bool isDueToday;

  const CadenceChip({
    super.key,
    required this.label,
    this.isDueToday = false,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: tokens.tonal,
        border: Border.all(
          color: isDueToday ? tokens.accent.withOpacity(0.5) : tokens.lineRule,
          width: 1,
        ),
      ),
      child: Text(
        label.toUpperCase(),
        style: tokens.monoText(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
          color: isDueToday ? tokens.accent : tokens.textSecondary,
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
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: tokens.tonal,
          border: Border.all(
            color: tokens.lineRest,
            width: 1,
          ),
        ),
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Frost subtle ring
            SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                value: 0.75,
                strokeWidth: 1.5,
                color: tokens.accent,
                backgroundColor: tokens.lineRule,
              ),
            ),
            Text(
              'L$level',
              style: tokens.monoText(
                fontSize: 12,
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

  const FreezeChip({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: tokens.tonal,
        border: Border.all(
          color: tokens.lineRest,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.ac_unit,
            size: 13,
            color: tokens.accent,
          ),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: tokens.monoText(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: tokens.textPrimary,
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
        isEssential ? Icons.star : Icons.star_border,
        size: 18,
        color: isEssential ? tokens.hero : tokens.textSecondary.withOpacity(0.4),
      ),
    );
  }
}
