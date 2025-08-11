import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/content_model.dart';
import '../models/product_model.dart';

class AdminProvider with ChangeNotifier {
  List<User> _users = [];
  List<Content> _contents = [];
  List<AdminProduct> _products = [];
  bool _isLoading = false;

  List<User> get users => _users;
  List<Content> get contents => _contents;
  List<AdminProduct> get products => _products;
  bool get isLoading => _isLoading;


  Future<void> loadInitialData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Fetch Users
      final usersSnapshot = await FirebaseFirestore.instance.collection('users').get();
      _users = usersSnapshot.docs.map((doc) {
        return User.fromMap(doc.data(), doc.id);
      }).toList();

      // Fetch Contents
      final contentsSnapshot = await FirebaseFirestore.instance.collection('posts').get();
      _contents = contentsSnapshot.docs.map((doc) {
        return Content.fromMap(doc.data(), doc.id);
      }).toList();

      // Fetch Products
      final productsSnapshot = await FirebaseFirestore.instance.collection('products').get();
      _products = productsSnapshot.docs.map((doc) {
        return AdminProduct.fromMap(doc.data(), doc.id);
      }).toList();

    } catch (e) {
      debugPrint("Error loading admin data: $e");
    }

    _isLoading = false;
    notifyListeners();
  }


  void addUser(User user) {
    _users.add(user);
    notifyListeners();
  }

  void updateUser(User updatedUser) {
    final index = _users.indexWhere((u) => u.id == updatedUser.id);
    if (index != -1) {
      _users[index] = updatedUser;
      notifyListeners();
    }
  }

  void deleteUser(String userId) {
    _users.removeWhere((u) => u.id == userId);
    notifyListeners();
  }

// Similar methods for content and products...
}