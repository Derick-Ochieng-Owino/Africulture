import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class FarmAnalyticsView extends StatelessWidget {
  const FarmAnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Daily Temperature', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          SizedBox(height: 200, child: _buildLineChart()),

          const SizedBox(height: 32),
          Text('Weekly Rainfall (mm)', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          SizedBox(height: 200, child: _buildBarChart()),

          const SizedBox(height: 32),
          Text('Crop Distribution', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          SizedBox(height: 200, child: _buildPieChart()),
        ],
      ),
    );
  }

  /// Line Chart: Daily Temperature
  Widget _buildLineChart() {
    final List<FlSpot> tempData = [
      FlSpot(0, 21),
      FlSpot(1, 23),
      FlSpot(2, 22),
      FlSpot(3, 25),
      FlSpot(4, 24),
      FlSpot(5, 26),
      FlSpot(6, 27),
    ];

    return LineChart(
      LineChartData(
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                return Text(days[value.toInt()]);
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: tempData,
            isCurved: true,
            color: Colors.orange,
            barWidth: 3,
            dotData: FlDotData(show: true),
          ),
        ],
        borderData: FlBorderData(show: false),
      ),
    );
  }

  /// Bar Chart: Weekly Rainfall
  Widget _buildBarChart() {
    final rainfall = [10.0, 30.0, 20.0, 50.0, 40.0, 15.0, 25.0];

    return BarChart(
      BarChartData(
        barGroups: rainfall.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value,
                color: Colors.blueAccent,
                width: 14,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                return Text(days[value.toInt()]);
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true),
          ),
        ),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  /// Pie Chart: Crop Distribution
  Widget _buildPieChart() {
    final data = [
      PieChartSectionData(
        value: 40,
        title: 'Maize',
        color: Colors.green,
        radius: 50,
      ),
      PieChartSectionData(
        value: 30,
        title: 'Beans',
        color: Colors.orange,
        radius: 50,
      ),
      PieChartSectionData(
        value: 20,
        title: 'Tomatoes',
        color: Colors.redAccent,
        radius: 50,
      ),
      PieChartSectionData(
        value: 10,
        title: 'Other',
        color: Colors.grey,
        radius: 50,
      ),
    ];

    return PieChart(
      PieChartData(
        sections: data,
        sectionsSpace: 2,
        centerSpaceRadius: 30,
      ),
    );
  }
}
