import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../theme/tokens.dart';

class CoachCardAction {
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  const CoachCardAction({
    required this.label,
    required this.onTap,
    this.isPrimary = true,
  });
}

class CoachCardWidget extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onDismiss;
  final List<CoachCardAction>? actions;
  final VoidCallback? onAction;
  final String? actionLabel;

  const CoachCardWidget({
    super.key,
    required this.title,
    required this.message,
    this.onDismiss,
    this.actions,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    final actionList = <CoachCardAction>[];
    if (actions != null && actions!.isNotEmpty) {
      actionList.addAll(actions!);
    } else if (onAction != null && actionLabel != null) {
      actionList.add(CoachCardAction(label: actionLabel!, onTap: onAction!));
    }

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
                    style: tokens.monoText(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: tokens.textPrimary,
                    ),
                  ),
                ],
              ),
              if (onDismiss != null)
                GestureDetector(
                  onTap: onDismiss,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(
                      Symbols.close,
                      size: 16,
                      color: tokens.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            message,
            style: tokens.body(
              fontSize: 14,
              color: tokens.textPrimary,
            ),
          ),
          if (actionList.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: actionList.map((act) {
                return GestureDetector(
                  onTap: act.onTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: act.isPrimary ? tokens.textPrimary : Colors.transparent,
                      border: Border.all(
                        color: act.isPrimary ? tokens.textPrimary : tokens.lineRule,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      act.label,
                      style: tokens.monoText(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: act.isPrimary ? tokens.onSolid : tokens.textPrimary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
