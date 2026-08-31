import 'package:flutter/material.dart';
import '../theme/tokens.dart';

class CheckboxRing extends StatelessWidget {
  final bool isCompleted;
  final bool isAtRisk;
  final bool isMissed;
  final VoidCallback? onTap;

  const CheckboxRing({
    super.key,
    required this.isCompleted,
    this.isAtRisk = false,
    this.isMissed = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    Color borderColor;
    Color? fillColor;
    Widget? icon;

    if (isCompleted) {
      borderColor = tokens.hero;
      fillColor = tokens.hero;
      icon = Icon(
        Icons.check,
        size: 16,
        color: tokens.onSolid,
      );
    } else if (isMissed) {
      borderColor = tokens.miss;
      fillColor = Colors.transparent;
    } else if (isAtRisk) {
      borderColor = tokens.accent;
      fillColor = Colors.transparent;
    } else {
      borderColor = tokens.textPrimary.withOpacity(0.40);
      fillColor = Colors.transparent;
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: fillColor,
          border: Border.all(
            color: borderColor,
            width: isMissed ? 2.0 : 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: icon,
      ),
    );
  }
}
