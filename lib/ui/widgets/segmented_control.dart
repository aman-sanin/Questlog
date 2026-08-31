import 'package:flutter/material.dart';
import '../theme/tokens.dart';

class SegmentItem<T> {
  final T value;
  final String label;

  const SegmentItem({
    required this.value,
    required this.label,
  });
}

class SegmentedControl<T> extends StatelessWidget {
  final List<SegmentItem<T>> items;
  final T selectedValue;
  final ValueChanged<T> onSelected;

  const SegmentedControl({
    super.key,
    required this.items,
    required this.selectedValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
      decoration: BoxDecoration(
        color: tokens.tonal,
        border: Border.all(color: tokens.lineRule, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: items.map((item) {
          final isSelected = item.value == selectedValue;

          return Expanded(
            child: GestureDetector(
              onTap: () => onSelected(item.value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? tokens.accent : Colors.transparent,
                ),
                alignment: Alignment.center,
                child: Text(
                  item.label.toUpperCase(),
                  style: tokens.monoText(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: isSelected ? tokens.onSolid : tokens.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
