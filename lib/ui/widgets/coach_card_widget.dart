import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import 'action_button.dart';

class CoachCardWidget extends StatelessWidget {
  final String title;
  final String body;
  final String primaryAction;
  final String? secondaryAction;
  final VoidCallback onPrimary;
  final VoidCallback? onSecondary;
  final VoidCallback onDismiss;

  const CoachCardWidget({
    super.key,
    required this.title,
    required this.body,
    required this.primaryAction,
    this.secondaryAction,
    required this.onPrimary,
    this.onSecondary,
    required this.onDismiss,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 18,
                color: tokens.accent,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: tokens.title(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: tokens.textPrimary,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onDismiss,
                child: Icon(
                  Icons.close,
                  size: 18,
                  color: tokens.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: tokens.body(
              fontSize: 13,
              color: tokens.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ActionButton(
                  label: primaryAction,
                  onPressed: onPrimary,
                  height: 38,
                  variant: ActionButtonVariant.primary,
                ),
              ),
              if (secondaryAction != null && onSecondary != null) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: ActionButton(
                    label: secondaryAction!,
                    onPressed: onSecondary,
                    height: 38,
                    variant: ActionButtonVariant.secondary,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
