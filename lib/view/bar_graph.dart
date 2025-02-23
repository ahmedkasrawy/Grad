import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MyBarGraph extends StatelessWidget {
  final List<double> weeklySummary;

  MyBarGraph({required this.weeklySummary});

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 200, // Assuming the max glucose reading will not exceed 200 mg/dL
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: getBottomTitles,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 20, // Display intervals on the Y-axis (50, 100, 150, 200)
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toString(),
                  style: TextStyle(color: Colors.black),
                );
              },
            ),
          ),
        ),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: true),
        barGroups: weeklySummary.asMap().entries.map((entry) {
          int index = entry.key;
          double value = entry.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: value,
                color: Colors.blue,
                width: 20,
                borderRadius: BorderRadius.circular(5),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  // Bottom titles (Monday-Sunday)
  Widget getBottomTitles(double value, TitleMeta meta) {
    const days = ['Sun','Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text(
        days[value.toInt()],
        style: TextStyle(color: Colors.black),
      ),
    );
  }
}