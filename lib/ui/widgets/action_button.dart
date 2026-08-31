import 'package:flutter/material.dart';
import '../theme/tokens.dart';

enum ActionButtonVariant {
  primary,
  secondary,
  ghost,
  destructive,
}

class ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final ActionButtonVariant variant;
  final Widget? icon;
  final bool isFullWidth;
  final double height;

  const ActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = ActionButtonVariant.primary,
    this.icon,
    this.isFullWidth = true,
    this.height = 48.0,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final isDisabled = onPressed == null;

    Color bg;
    Color textColor;
    Border? border;

    switch (variant) {
      case ActionButtonVariant.primary:
        bg = isDisabled ? tokens.lineRule : tokens.textPrimary;
        textColor = tokens.onSolid;
        border = null;
        break;
      case ActionButtonVariant.secondary:
        bg = tokens.tonal;
        textColor = isDisabled ? tokens.textSecondary.withOpacity(0.5) : tokens.textPrimary;
        border = Border.all(color: tokens.lineRest, width: 1);
        break;
      case ActionButtonVariant.ghost:
        bg = Colors.transparent;
        textColor = tokens.textSecondary;
        border = Border.all(color: Colors.transparent, width: 1);
        break;
      case ActionButtonVariant.destructive:
        bg = tokens.miss.withOpacity(0.12);
        textColor = tokens.miss;
        border = Border.all(color: tokens.miss.withOpacity(0.4), width: 1);
        break;
    }

    Widget content = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          icon!,
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: tokens.body(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ],
    );

    return InkWell(
      onTap: onPressed,
      child: Container(
        height: height,
        width: isFullWidth ? double.infinity : null,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: bg,
          border: border,
        ),
        alignment: Alignment.center,
        child: content,
      ),
    );
  }
}
