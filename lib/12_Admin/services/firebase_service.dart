import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/analytics_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Users Collection
  Future<List<Map<String, dynamic>>> getUsers() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      debugPrint('Error fetching all users: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getUser(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.data();
    } catch (e) {
      debugPrint('Error fetching user $userId: $e');
      return null;
    }
  }

  // Content Collection
  Future<List<Map<String, dynamic>>> getContent() async {
    final snapshot = await _firestore.collection('posts').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  // Orders Collection
  Future<List<Map<String, dynamic>>> getOrders() async {
    final snapshot = await _firestore.collection('orders').get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  // Analytics Collection
  Future<Analytics> getAnalytics() async {
    final doc = await FirebaseFirestore.instance.collection('analytics').doc('dashboard').get();

    if (!doc.exists) {
      throw Exception("No analytics data found in Firestore");
    }

    final data = doc.data();
    if (data == null) {
      throw Exception("No analytics data found in Firestore");
    }

    return Analytics(
      totalUsers: data['totalUsers'] ?? 0,
      activeUsers: data['activeUsers'] ?? 0,
      totalProducts: data['totalProducts'] ?? 0,
      totalOrders: data['totalOrders'] ?? 0,
      totalRevenue: (data['totalRevenue'] ?? 0).toDouble(),
      revenueData: (data['revenueData'] as List<dynamic>)
          .map((e) => RevenueData(
        date: (e as Map<String, dynamic>)['date'] != null
            ? ((e['date']) as Timestamp).toDate()
            : DateTime.now(),
        amount: (e['amount'] ?? 0).toDouble(),
      ))
          .toList(),
      userGrowth: (data['userGrowth'] as List<dynamic>)
          .map((e) => UserGrowth(
        date: (e as Map<String, dynamic>)['date'] != null
            ? ((e['date']) as Timestamp).toDate()
            : DateTime.now(),
        count: e['count'] ?? 0,
      ))
          .toList(),
      topProducts: (data['topProducts'] as List<dynamic>)
          .map((e) =>
          ProductPerformance.fromFirestore(e as Map<String, dynamic>))
          .toList(),
    );
  }
}