import 'package:cloud_firestore/cloud_firestore.dart';

class Analytics {
  final int totalUsers;
  final int activeUsers;
  final int totalProducts;
  final int totalOrders;
  final double totalRevenue;
  final List<RevenueData> revenueData;
  final List<UserGrowth> userGrowth;
  final List<ProductPerformance> topProducts;

  Analytics({
    required this.totalUsers,
    required this.activeUsers,
    required this.totalProducts,
    required this.totalOrders,
    required this.totalRevenue,
    required this.revenueData,
    required this.userGrowth,
    required this.topProducts,
  });

  factory Analytics.fromJson(Map<String, dynamic> json) {
    return Analytics(
      totalUsers: json['totalUsers'] ?? 0,
      activeUsers: json['activeUsers'] ?? 0,
      totalProducts: json['totalProducts'] ?? 0,
      totalOrders: json['totalOrders'] ?? 0,
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      revenueData: (json['revenueData'] as List<dynamic>? ?? [])
          .map((e) => RevenueData.fromFirestore(e as Map<String, dynamic>))
          .toList(),
      userGrowth: (json['userGrowth'] as List<dynamic>? ?? [])
          .map((e) => UserGrowth.fromFirestore(e as Map<String, dynamic>))
          .toList(),
      topProducts: (json['topProducts'] as List<dynamic>? ?? [])
          .map((e) => ProductPerformance.fromFirestore(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class RevenueData {
  final DateTime date;
  final double amount;

  RevenueData({required this.date, required this.amount});

  factory RevenueData.fromFirestore(Map<String, dynamic> json) {
    final dateField = json['date'];
    print('Parsing RevenueData from json: $json');  // debug

    DateTime date;
    if (dateField is Timestamp) {
      date = dateField.toDate();
      print('dateField is Timestamp, converted to DateTime: $date'); // debug
    } else if (dateField is String) {
      date = DateTime.tryParse(dateField) ?? DateTime.now();
      print('dateField is String, parsed DateTime: $date'); // debug
    } else {
      date = DateTime.now();
      print('dateField unknown type, defaulting to now: $date'); // debug
    }

    final amount = (json['amount'] ?? 0).toDouble();
    print('Parsed amount: $amount'); // debug

    return RevenueData(
      date: date,
      amount: amount,
    );
  }
}

class UserGrowth {
  final DateTime date;
  final int count;

  UserGrowth({required this.date, required this.count});

  factory UserGrowth.fromFirestore(Map<String, dynamic> json) {
    final dateField = json['date'];
    DateTime date;

    if (dateField is Timestamp) {
      date = dateField.toDate();
    } else if (dateField is String) {
      date = DateTime.tryParse(dateField) ?? DateTime.now();
    } else {
      date = DateTime.now();
    }

    return UserGrowth(
      date: date,
      count: json['count'] ?? 0,
    );
  }
}

class ProductPerformance {
  final String productId;
  final String name;
  final int sales;
  final double revenue;

  ProductPerformance({
    required this.productId,
    required this.name,
    required this.sales,
    required this.revenue,
  });

  factory ProductPerformance.fromFirestore(Map<String, dynamic> json) {
    return ProductPerformance(
      productId: json['productId'] ?? '',
      name: json['name'] ?? '',
      sales: json['sales'] ?? 0,
      revenue: (json['revenue'] ?? 0).toDouble(),
    );
  }
}
