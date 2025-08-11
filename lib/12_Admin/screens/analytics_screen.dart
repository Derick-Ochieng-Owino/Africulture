import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/analytics_model.dart';
import '../widgets/common/app_bar.dart';
import '../widgets/common/app_drawer.dart';
import '../widgets/common/stat_card.dart';
import '../widgets/charts/bar_chart_widget.dart';
import '../widgets/charts/line_chart_widget.dart';
import '../widgets/charts/pie_chart_widget.dart';
import '../providers/analytics_provider.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  late Future<void> _analyticsFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _analyticsFuture =
          Provider.of<AnalyticsProvider>(context, listen: false).loadAnalytics();
    });
  }

  @override
  Widget build(BuildContext context) {
    final analyticsProvider = Provider.of<AnalyticsProvider>(context);
    final analytics = analyticsProvider.analyticsData;

    if (analyticsProvider.isLoading || analytics == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final List<RevenueData> revenueTrend = (analytics['revenueTrend'] is List)
        ? (analytics['revenueTrend'] as List)
        .map((item) => RevenueData.fromFirestore(Map<String, dynamic>.from(item)))
        .toList()
        : [];

    final List<UserGrowth> userGrowth = (analytics['userGrowth'] is List)
        ? (analytics['userGrowth'] as List)
        .map((item) => UserGrowth.fromFirestore(Map<String, dynamic>.from(item)))
        .toList()
        : [];

    final List<ProductPerformance> topProducts = (analytics['topProductsList'] is List)
        ? (analytics['topProductsList'] as List)
        .map((item) => ProductPerformance.fromFirestore(Map<String, dynamic>.from(item)))
        .toList()
        : [];
    return Scaffold(
      drawer: AdminDrawer(
        userName: 'userName',
        userEmail: 'userEmail',
        profileImageUrl: 'profileImageUrl',
        location: 'location',
      ),
      appBar: AdminAppBar(title: 'Analytics Dashboard'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    setState(() {
                      _analyticsFuture =
                          Provider.of<AnalyticsProvider>(context, listen: false)
                              .loadAnalytics();
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                StatCard(
                  icon: Icons.people,
                  title: 'Total Users',
                  value: analytics['totalUsers'].toString(),
                  subtitle: '${analytics['activeUsers']} active',
                  color: Colors.blue,
                ),
                StatCard(
                  icon: Icons.shopping_cart,
                  title: 'Total Orders',
                  value: analytics['totalOrders'].toString(),
                  subtitle:
                  '\$${analytics['totalRevenue'].toStringAsFixed(2)} revenue',
                  color: Colors.green,
                ),
                StatCard(
                  icon: Icons.inventory,
                  title: 'Total Products',
                  value: analytics['totalProducts'].toString(),
                  subtitle: '${topProducts.length} top sellers',
                  color: Colors.purple,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text('Revenue Trend', style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 300,
                      child: LineChartWidget(
                        data: revenueTrend
                            .map((item) =>
                            RevenueData.fromFirestore(item as Map<String, dynamic>))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text('User Growth'),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 250,
                            child: BarChartWidget(data: userGrowth),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text('Revenue Breakdown'),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 250,
                            child: PieChartWidget(data: topProducts),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
