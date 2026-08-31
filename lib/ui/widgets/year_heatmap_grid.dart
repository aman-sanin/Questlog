import 'package:flutter/material.dart';
import '../../app/providers/insights_provider.dart';
import '../../domain/model/models.dart';
import '../theme/tokens.dart';

class YearHeatmapGrid extends StatelessWidget {
  final List<HeatmapDayStatus> days;
  final WeekStart weekStart;
  final ValueChanged<LocalDate>? onDaySelected;

  const YearHeatmapGrid({
    super.key,
    required this.days,
    required this.weekStart,
    this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    if (days.isEmpty) return const SizedBox.shrink();

    // Group days into columns of 7 days (weeks)
    final firstDay = days.first.date;
    final int firstWeekday = firstDay.toDateTime().weekday; // 1=Mon, 7=Sun
    final int leadingEmpty = weekStart == WeekStart.sunday
        ? (firstWeekday % 7)
        : (firstWeekday - 1);

    final List<List<HeatmapDayStatus?>> columns = [];
    List<HeatmapDayStatus?> currentColumn = List.filled(leadingEmpty, null, growable: true);

    for (final day in days) {
      currentColumn.add(day);
      if (currentColumn.length == 7) {
        columns.add(currentColumn);
        currentColumn = [];
      }
    }
    if (currentColumn.isNotEmpty) {
      while (currentColumn.length < 7) {
        currentColumn.add(null);
      }
      columns.add(currentColumn);
    }

    final rowLabels = weekStart == WeekStart.sunday
        ? ['', 'M', '', 'W', '', 'F', '']
        : ['M', '', 'W', '', 'F', '', 'S'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      reverse: true, // Scroll to end (today) by default
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day of week labels on left
          Column(
            children: List.generate(7, (index) {
              return Container(
                width: 14,
                height: 14,
                margin: const EdgeInsets.only(bottom: 3, right: 6),
                alignment: Alignment.center,
                child: Text(
                  rowLabels[index],
                  style: tokens.monoText(
                    fontSize: 9,
                    color: tokens.textSecondary.withOpacity(0.6),
                  ),
                ),
              );
            }),
          ),
          // Week columns
          Row(
            children: columns.map((col) {
              return Padding(
                padding: const EdgeInsets.only(right: 3),
                child: Column(
                  children: col.map<Widget>((day) {
                    if (day == null) {
                      return Container(width: 14, height: 14, margin: const EdgeInsets.only(bottom: 3));
                    }

                    Color dotColor = tokens.textPrimary.withOpacity(0.06);
                    Border? dotBorder;

                    switch (day.intensity) {
                      case HeatmapIntensity.offDay:
                        dotColor = tokens.textPrimary.withOpacity(0.06);
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
                        width: 14,
                        height: 14,
                        margin: const EdgeInsets.only(bottom: 3),
                        decoration: BoxDecoration(
                          color: dotColor,
                          border: dotBorder,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
