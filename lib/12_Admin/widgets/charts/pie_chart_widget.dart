import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/analytics_model.dart';

class PieChartWidget extends StatelessWidget {
  final List<ProductPerformance> data;
  final double chartRadius;

  const PieChartWidget({
    super.key,
    required this.data,
    this.chartRadius = 100,
  });

  @override
  Widget build(BuildContext context) {
    final totalRevenue = data.fold(0.0, (sum, item) => sum + item.revenue);

    return PieChart(
      PieChartData(
        sectionsSpace: 0,
        centerSpaceRadius: chartRadius * 0.4,
        sections: data.map((product) {
          final percentage = totalRevenue == 0
              ? 0
              : (product.revenue / totalRevenue * 100).round();

          return PieChartSectionData(
            color: _getColorForProduct(product.productId),
            value: product.revenue,
            title: '${percentage}%',
            radius: chartRadius,
            titleStyle: TextStyle(
              fontSize: chartRadius * 0.12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _getColorForProduct(String productId) {
    final colors = [Colors.blue, Colors.green, Colors.orange, Colors.purple];
    int index;
    try {
      index = int.parse(productId) % colors.length;
    } catch (_) {
      index = productId.hashCode % colors.length;
    }
    return colors[index];
  }

}