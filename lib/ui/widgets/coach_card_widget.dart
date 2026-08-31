import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../theme/tokens.dart';

class CoachCardWidget extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onDismiss;
  final VoidCallback? onAction;
  final String? actionLabel;

  const CoachCardWidget({
    super.key,
    required this.title,
    required this.message,
    this.onDismiss,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
      padding: const EdgeInsets.all(16),
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
              Row(
                children: [
                  Icon(
                    Symbols.lightbulb,
                    size: 18,
                    color: tokens.accent,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title.toUpperCase(),
                    style: tokens.title(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: tokens.textPrimary,
                    ),
                  ),
                ],
              ),
              if (onDismiss != null)
                GestureDetector(
                  onTap: onDismiss,
                  child: Icon(
                    Symbols.close,
                    size: 16,
                    color: tokens.textSecondary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: tokens.body(
              fontSize: 13,
              color: tokens.textSecondary,
            ),
          ),
          if (onAction != null && actionLabel != null) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: onAction,
              child: Text(
                actionLabel!,
                style: tokens.monoText(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: tokens.accent,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
