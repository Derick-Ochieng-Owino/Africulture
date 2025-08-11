import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/analytics_model.dart';
import '../services/firebase_service.dart';

class AnalyticsProvider with ChangeNotifier {
  List<UserGrowth> _userGrowth = [];
  List<ProductPerformance> _topProducts = [];
  List<RevenueData> _revenueData = [];

  List<UserGrowth> get userGrowth => _userGrowth;
  List<ProductPerformance> get topProducts => _topProducts;
  List<RevenueData> get revenueData => _revenueData;

  Map<String, dynamic>? analyticsData;
  bool isLoading = false;
  String? _error;

  Future<void> loadAnalytics() async {
    isLoading = true;
    notifyListeners();

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('analytics')
          .doc('dashboard')
          .get();

      if (!snapshot.exists) {
        throw Exception('Analytics document not found');
      }

      final data = snapshot.data();

      if (data == null) {
        throw Exception('No data in analytics dashboard document');
      }

      // Parse userGrowth list
      final List<dynamic> userGrowthRaw = data['userGrowth'] ?? [];
      _userGrowth = userGrowthRaw.map((item) {
        final map = Map<String, dynamic>.from(item);
        return UserGrowth(
          count: map['count'] ?? 0,
          date: (map['date'] as Timestamp).toDate(),
        );
      }).toList();


      // Parse topProducts list
      final List<dynamic> topProductsRaw = data['topProducts'] ?? [];
      _topProducts = topProductsRaw.map((item) {
        final map = Map<String, dynamic>.from(item);
        return ProductPerformance(
          productId: map['productId'] ?? '',
          name: map['name'] ?? '',
          sales: (map['totalOrders'] ?? 0) as int,
          revenue: 0, // If you have revenue info, map here
        );
      }).toList();

      // Parse Revenue data list
      final List<dynamic> revenueDataRaw = data['revenueData'] ?? [];
      _revenueData = revenueDataRaw.map((item) {
        final map = Map<String, dynamic>.from(item);
        return RevenueData(
          date: (map['date'] as Timestamp).toDate(),
          amount: (map['amount'] ?? 0).toDouble(),
        );
      }).toList();

      // You can store other fields too if you want
      analyticsData = data;

    } catch (e) {
      debugPrint('Error loading analytics: $e');
      _error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}