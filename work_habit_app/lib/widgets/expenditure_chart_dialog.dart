import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class ExpenditureChartDialog extends StatelessWidget {
  ExpenditureChartDialog({Key? key}) : super(key: key);

  // Generate sample data for 30 days of the month
  final List<FlSpot> sampleData = List.generate(30, (index) {
    return FlSpot(index.toDouble() + 1, Random().nextDouble() * 100);
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Expenditure - This Month"),
      content: SizedBox(
        width: double.maxFinite,
        height: 250,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: true),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  interval: 5,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toInt().toString(),
                      style: const TextStyle(fontSize: 10),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  interval: 20,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toInt().toString(),
                      style: const TextStyle(fontSize: 10),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: true),
            lineBarsData: [
              LineChartBarData(
                spots: sampleData,
                isCurved: true,
                barWidth: 3,
                dotData: FlDotData(show: true),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Close"),
        ),
      ],
    );
  }
}
