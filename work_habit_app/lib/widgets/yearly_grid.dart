import 'package:flutter/material.dart';

/// Formats a DateTime into a string key (adjust as needed)
String formatDate(DateTime date) {
  return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
}

/// A widget that builds the yearly contribution grid.
class YearlyGrid extends StatelessWidget {
  final Map<String, bool> trackedMap;

  const YearlyGrid({Key? key, required this.trackedMap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DateTime start = DateTime(DateTime.now().year, 1, 1);
    final DateTime end = DateTime(DateTime.now().year, 12, 31);
    List<DateTime> days = [];
    for (DateTime d = start; !d.isAfter(end); d = d.add(const Duration(days: 1))) {
      days.add(d);
    }
    int padStart = start.weekday % 7;
    List<DateTime?> gridDays = List<DateTime?>.filled(padStart, null, growable: true);
    gridDays.addAll(days);
    int remainder = gridDays.length % 7;
    if (remainder != 0) {
      int padEnd = 7 - remainder;
      gridDays.addAll(List<DateTime?>.filled(padEnd, null));
    }
    int weekCount = gridDays.length ~/ 7;
    List<List<DateTime?>> weeks = [];
    for (int i = 0; i < weekCount; i++) {
      weeks.add(gridDays.sublist(i * 7, i * 7 + 7));
    }
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final colorScheme = Theme.of(context).colorScheme;
        double availableWidth = constraints.maxWidth;
        double squareSize = availableWidth / weekCount;
        squareSize = squareSize.clamp(6.0, 12.0);
        double effectiveSquareWidth = squareSize + 2;
        double totalWidth = weekCount * effectiveSquareWidth;
        List<String> monthsFull = [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sept', 'Oct', 'Nov', 'Dec'
        ];
        List<Widget> monthLabels = [];
        for (int month = 1; month <= 12; month++) {
          DateTime monthFirst = DateTime(DateTime.now().year, month, 1);
          int dayOffset = monthFirst.difference(start).inDays;
          int indexInGrid = padStart + dayOffset;
          int columnIndex = indexInGrid ~/ 7;
          double leftOffset = columnIndex * effectiveSquareWidth;
          monthLabels.add(Positioned(
            left: leftOffset,
            child: Text(
              monthsFull[month - 1],
              style: TextStyle(
                fontSize: 10,
                color:  Colors.grey,
              ),
            ),
          ));
        }
        Widget monthLabelsRow = Container(
          width: totalWidth,
          height: 14,
          child: Stack(children: monthLabels),
        );
        List<Widget> weekColumns = weeks.map((week) {
          List<Widget> dayCells = week.map((day) {
            if (day == null) return Container(width: squareSize, height: squareSize);
            String key = formatDate(day);
            bool tracked = trackedMap[key] ?? false;
            return Container(
              width: squareSize,
              height: squareSize,
              margin: const EdgeInsets.only(bottom: 2),
              color: tracked
                  ? Colors.blue
                  : (isDarkMode ? Colors.grey[500] : Colors.grey[300]),
            );
          }).toList();
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: dayCells,
          );
        }).toList();
        Widget grid = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: weekColumns
              .map((col) => Padding(
            padding: const EdgeInsets.only(right: 2),
            child: col,
          ))
              .toList(),
        );
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [monthLabelsRow, const SizedBox(height: 2), grid],
          ),
        );
      },
    );
  }
}
