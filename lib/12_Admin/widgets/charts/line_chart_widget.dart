import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/analytics_model.dart';

class LineChartWidget extends StatelessWidget {
  final List<RevenueData> data;

  const LineChartWidget({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    // Handle empty data case
    if (data.isEmpty) {
      return const Center(
        child: Text('No data available'),
      );
    }

    // Calculate maxY safely
    // final maxY = data.isNotEmpty
    //     ? data.map((e) => e.amount).reduce((a, b) => a > b ? a : b) * 1.1
    //     : 10; // Default value when empty

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: data.length.toDouble() - 1,
        minY: 0,
        maxY: 30.0,
        lineBarsData: [
          LineChartBarData(
            spots: data.asMap().entries.map((e) {
              return FlSpot(e.key.toDouble(), e.value.amount);
            }).toList(),
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.1)),
          ),
        ],
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text('Day ${value.toInt() + 1}');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text('\$${value.toInt()}');
              },
            ),
          ),
        ),
      ),
    );
  }
}