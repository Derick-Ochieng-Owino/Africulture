import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class ProductService with ChangeNotifier {
  final List<Product> _products = [];
  final List<Product> _searchResults = [];

  bool _isLoading = true;
  String? _error;
  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Product> get products => _products;
  List<Product> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;

  Future<void> loadProducts({bool refresh = false}) async {
    if (refresh) {
      _products.clear();
      _lastDocument = null;
      _hasMore = true;
    }

    if (!_hasMore) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      Query query = _firestore
          .collection('products')
          .where('approved', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(20);

      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      final snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        _hasMore = false;
      } else {
        _lastDocument = snapshot.docs.last;
        _products.addAll(
          snapshot.docs.map((doc) => Product.fromFirestore(doc)),
        );
      }
    } catch (e) {
      _error = 'Failed to load products: ${e.toString()}';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshProducts() async {
    await loadProducts(refresh: true);
  }

  List<Product> getProductsByCategory(String category) {
    return _products.where((p) => p.category == category).toList();
  }

  List<String> getCategories() {
    return _products.map((p) => p.category).toSet().toList()
      ..sort((a, b) => a.compareTo(b));
  }

  Future<void> searchProducts(String query) async {
    try {
      _isLoading = true;
      notifyListeners();

      final snapshot = await _firestore
          .collection('products')
          .where('approved', isEqualTo: true)
          .where('searchKeywords', arrayContains: query.toLowerCase())
          .limit(50)
          .get();

      _searchResults.clear();
      _searchResults.addAll(
        snapshot.docs.map((doc) => Product.fromFirestore(doc)),
      );
      _error = null;
    } catch (e) {
      _error = 'Search failed: ${e.toString()}';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _searchResults.clear();
    notifyListeners();
  }
}
