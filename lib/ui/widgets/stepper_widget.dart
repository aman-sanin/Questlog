import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../theme/tokens.dart';

class StepperWidget extends StatelessWidget {
  final int current;
  final int target;
  final String? unit;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;

  const StepperWidget({
    super.key,
    required this.current,
    required this.target,
    this.unit,
    this.onIncrement,
    this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final isOverachieved = current > target;
    final isDone = current >= target;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Decrement button
        GestureDetector(
          onTap: current > 0 ? onDecrement : null,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: tokens.tonal,
              border: Border.all(color: tokens.lineRule, width: 1),
            ),
            alignment: Alignment.center,
            child: Icon(
              Symbols.remove,
              size: 14,
              color: current > 0 ? tokens.textPrimary : tokens.textSecondary.withOpacity(0.3),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Count Text
        Text(
          '$current/$target${unit != null ? " $unit" : ""}',
          style: tokens.monoText(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isOverachieved
                ? tokens.accent
                : (isDone ? tokens.hero : tokens.textPrimary),
          ),
        ),
        const SizedBox(width: 8),

        // Increment button
        GestureDetector(
          onTap: onIncrement,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isDone ? tokens.hero : tokens.tonal,
              border: Border.all(
                color: isDone ? tokens.hero : tokens.lineRule,
                width: 1,
              ),
            ),
            alignment: Alignment.center,
            child: Icon(
              Symbols.add,
              size: 14,
              color: isDone ? tokens.onSolid : tokens.textPrimary,
              weight: 700,
            ),
          ),
        ),
      ],
    );
  }
}
