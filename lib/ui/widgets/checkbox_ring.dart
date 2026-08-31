import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../theme/tokens.dart';

class CheckboxRing extends StatelessWidget {
  final bool isCompleted;
  final bool isAtRisk;
  final bool isMissed;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const CheckboxRing({
    super.key,
    this.isCompleted = false,
    this.isAtRisk = false,
    this.isMissed = false,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    Color borderColor;
    Color? fillColor;

    if (isCompleted) {
      borderColor = tokens.hero;
      fillColor = tokens.hero;
    } else if (isAtRisk) {
      borderColor = tokens.accent;
      fillColor = null;
    } else {
      borderColor = tokens.lineRest;
      fillColor = null;
    }

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: fillColor,
          border: Border.all(
            color: borderColor,
            width: isCompleted ? 0 : (isAtRisk ? 2.0 : 1.5),
          ),
        ),
        alignment: Alignment.center,
        child: isCompleted
            ? Icon(
                Symbols.check,
                size: 16,
                color: tokens.onSolid,
                weight: 700,
              )
            : null,
      ),
    );
  }
}
