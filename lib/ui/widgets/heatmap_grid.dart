import 'package:flutter/material.dart';
import '../../app/providers/insights_provider.dart';
import '../../domain/model/models.dart';
import '../theme/tokens.dart';

class HeatmapGrid extends StatelessWidget {
  final List<HeatmapDayStatus> days;
  final WeekStart weekStart;
  final ValueChanged<LocalDate>? onDaySelected;

  const HeatmapGrid({
    super.key,
    required this.days,
    required this.weekStart,
    this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final headers = weekStart == WeekStart.sunday
        ? ['S', 'M', 'T', 'W', 'T', 'F', 'S']
        : ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    if (days.isEmpty) {
      return const SizedBox.shrink();
    }

    final firstDay = days.first.date;
    final int firstWeekday = firstDay.toDateTime().weekday; // 1=Mon, 7=Sun
    final int leadingEmptyCells = weekStart == WeekStart.sunday
        ? (firstWeekday % 7)
        : (firstWeekday - 1);

    return Column(
      children: [
        // Day of week headers
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: headers
              .map((h) => Expanded(
                    child: Center(
                      child: Text(
                        h,
                        style: tokens.monoText(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: tokens.textSecondary,
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 8),
        // Grid of dots
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
            childAspectRatio: 1.0,
          ),
          itemCount: leadingEmptyCells + days.length,
          itemBuilder: (context, index) {
            if (index < leadingEmptyCells) {
              return const SizedBox.shrink();
            }

            final day = days[index - leadingEmptyCells];
            Color dotColor = tokens.textPrimary.withOpacity(0.08);
            Border? dotBorder;

            switch (day.intensity) {
              case HeatmapIntensity.offDay:
                dotColor = tokens.textPrimary.withOpacity(0.08);
                break;
              case HeatmapIntensity.paused:
                dotColor = Colors.transparent;
                dotBorder = Border.all(color: tokens.lineRule, width: 1);
                break;
              case HeatmapIntensity.missedEssential:
                dotColor = tokens.miss;
                break;
              case HeatmapIntensity.low:
                dotColor = tokens.accent.withOpacity(0.20);
                break;
              case HeatmapIntensity.medium:
                dotColor = tokens.accent.withOpacity(0.45);
                break;
              case HeatmapIntensity.high:
                dotColor = tokens.accent.withOpacity(0.70);
                break;
              case HeatmapIntensity.perfect:
                dotColor = tokens.hero;
                break;
            }

            if (day.isToday) {
              dotBorder = Border.all(color: tokens.accent, width: 1.5);
            }

            return GestureDetector(
              onTap: () => onDaySelected?.call(day.date),
              child: Container(
                decoration: BoxDecoration(
                  color: dotColor,
                  border: dotBorder,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
