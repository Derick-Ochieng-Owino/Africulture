import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/analytics_provider.dart';
import '../models/analytics_model.dart';
import '../widgets/charts/bar_chart_widget.dart';
import '../widgets/charts/line_chart_widget.dart';
import '../widgets/charts/pie_chart_widget.dart';
import '../widgets/common/stat_card.dart';
import '../widgets/common/app_bar.dart';
import '../widgets/common/app_drawer.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String username = '';
  String userEmail = '';
  String profileImageUrl = '';
  String userLocation = '';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AnalyticsProvider>(context, listen: false).loadAnalytics();
    });
  }

  Future<void> _loadUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance.collection('farmers').doc(user.uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        username = data['name'] ?? 'Admin';
        userEmail = user.email ?? '';
        profileImageUrl = data['profileImageUrl'] ?? '';
        userLocation = data['location'] ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final analyticsProvider = Provider.of<AnalyticsProvider>(context);
    final analyticsData = analyticsProvider.analyticsData;
    final topProducts = analyticsProvider.topProducts;

    return Scaffold(
      appBar: AdminAppBar(title: 'AdminDashBoard'),
      drawer: AdminDrawer(
        userName: username,
        userEmail: userEmail,
        profileImageUrl: profileImageUrl,
        location: userLocation,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                StatCard(
                  icon: Icons.people,
                  title: 'Total Users',
                  valueWidget: StreamBuilder<int>(
                    stream: userCountStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return const Text('Error');
                      } else {
                        return Text(snapshot.data.toString());
                      }
                    },
                  ),
                  subtitle: 'Real-time count',
                  color: Colors.green,
                ),

                StatCard(
                  icon: Icons.inventory,
                  title: 'Total Products',
                  value: '245',
                  subtitle: '↑ 15% from last month',
                  color: Colors.blue,
                ),
                StatCard(
                  icon: Icons.attach_money,
                  title: 'Total Revenue',
                  value: '\$24,521',
                  subtitle: '↑ 33% from last month',
                  color: Colors.purple,
                ),
                StatCard(
                  icon: Icons.warning,
                  title: 'Active Alerts',
                  value: '2',
                  subtitle: 'Requires attention',
                  color: Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 20),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'User Growth (Last 30 Days)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 200,
                      child: BarChartWidget(data: analyticsProvider.userGrowth),
                    ),
                    const Text(
                      'Revenue Data',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 200,
                      child: LineChartWidget(data: analyticsProvider.revenueData),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Top Products Revenue',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 300,
                      child: PieChartWidget(data: analyticsProvider.topProducts),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Stream<int> userCountStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}