import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = false;
  bool _isAdmin = false;

  List<Map<String, dynamic>> get users => _users;
  bool get isLoading => _isLoading;
  bool get isAdmin => _isAdmin;

  Future<void> updateUserOnlineStatus(bool isOnline) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      await _firestore.collection('users').doc(user.uid).update({
        'isOnline': isOnline,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Failed to update online status: $e');
    }
  }

  Future<void> _checkAdminStatus() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _isAdmin = false;
        return;
      }

      final idToken = await user.getIdTokenResult();
      debugPrint('User claims: ${idToken.claims}');
      _isAdmin = idToken.claims?['admin'] == true;
      debugPrint('Is admin? $_isAdmin');
    } catch (e) {
      debugPrint('Admin check error: $e');
      _isAdmin = false;
    }
  }


  Future<void> loadAllUsers() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('users')
          .orderBy('createdAt', descending: true)
          .get();

      _users = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'firstName': data['firstName'] ?? '',
          'lastName': data['lastName'] ?? '',
          'email': data['email'] ?? '',
          'userType': data['userType'] ?? '',
          'status': data['status'] ?? '',
          'isOnline': data['isOnline'] ?? false,
        };
      }).toList();
    } catch (e) {
      debugPrint('User load error: $e');
      _users = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<void> updateUserRoleStatus(
      String userId,
      String newRole,
      String newStatus,
      ) async {
    debugPrint('Called updateUserRoleStatus with: userId=$userId, newRole=$newRole, newStatus=$newStatus');
    try {
      await _firestore.collection('users').doc(userId).update({
        'userType': newRole,
        'status': newStatus,
      });
      debugPrint('Firestore update successful');
    } catch (e) {
      debugPrint('Failed to update user role/status: $e');
      rethrow;
    }
  }
}
