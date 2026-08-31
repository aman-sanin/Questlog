import 'package:flutter/material.dart';
import '../theme/tokens.dart';

class StatCard extends StatelessWidget {
  final String value;
  final String label;
  final String? subLabel;
  final Widget? trailing;

  const StatCard({
    super.key,
    required this.value,
    required this.label,
    this.subLabel,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tokens.bg,
        border: Border.all(color: tokens.lineRest, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: tokens.monoText(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: tokens.textPrimary,
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 6),
          Text(
            label.toUpperCase(),
            style: tokens.monoText(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.0,
              color: tokens.textSecondary,
            ),
          ),
          if (subLabel != null) ...[
            const SizedBox(height: 4),
            Text(
              subLabel!,
              style: tokens.body(
                fontSize: 12,
                color: tokens.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
