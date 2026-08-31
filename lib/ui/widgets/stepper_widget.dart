import 'package:flutter/material.dart';
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
    final bool canDecrement = current > 0;
    final bool isCompleted = current >= target;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Decrement button
        InkWell(
          onTap: canDecrement ? onDecrement : null,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: tokens.tonal,
              border: Border.all(
                color: canDecrement ? tokens.lineRest : tokens.lineRule,
                width: 1,
              ),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.remove,
              size: 16,
              color: canDecrement ? tokens.textPrimary : tokens.textSecondary.withOpacity(0.4),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Monospace count
        Text(
          unit != null ? '$current/$target $unit' : '$current/$target',
          style: tokens.monoText(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isCompleted ? tokens.hero : tokens.textPrimary,
          ),
        ),
        const SizedBox(width: 10),
        // Increment button
        InkWell(
          onTap: onIncrement,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isCompleted ? tokens.hero.withOpacity(0.15) : tokens.tonal,
              border: Border.all(
                color: isCompleted ? tokens.hero : tokens.lineRest,
                width: 1,
              ),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.add,
              size: 16,
              color: isCompleted ? tokens.hero : tokens.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
