import 'package:flutter/material.dart';
import '../theme/tokens.dart';

class WeekdayToggles extends StatelessWidget {
  final Set<int> selectedDays; // 1 = Mon, 7 = Sun
  final ValueChanged<Set<int>> onChanged;

  const WeekdayToggles({
    super.key,
    required this.selectedDays,
    required this.onChanged,
  });

  static const List<String> _labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final dayNumber = index + 1;
        final isSelected = selectedDays.contains(dayNumber);

        return GestureDetector(
          onTap: () {
            final next = Set<int>.from(selectedDays);
            if (isSelected) {
              if (next.length > 1) {
                next.remove(dayNumber);
              }
            } else {
              next.add(dayNumber);
            }
            onChanged(next);
          },
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isSelected ? tokens.accent : tokens.tonal,
              border: Border.all(
                color: isSelected ? tokens.accent : tokens.lineRest,
                width: 1.5,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              _labels[index],
              style: tokens.monoText(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? tokens.onSolid : tokens.textSecondary,
              ),
            ),
          ),
        );
      }),
    );
  }
}
