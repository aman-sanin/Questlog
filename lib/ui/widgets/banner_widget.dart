import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../theme/tokens.dart';

class PerfectDayBanner extends StatelessWidget {
  final VoidCallback? onTap;

  const PerfectDayBanner({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: tokens.tonal,
        border: Border(
          bottom: BorderSide(color: tokens.lineRule, width: 1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Symbols.auto_awesome,
            size: 18,
            color: tokens.hero,
            fill: 1.0,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'PERFECT DAY',
              style: tokens.title(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: tokens.textPrimary,
              ),
            ),
          ),
          Text(
            '+15 XP',
            style: tokens.monoText(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: tokens.hero,
            ),
          ),
        ],
      ),
    );
  }
}
