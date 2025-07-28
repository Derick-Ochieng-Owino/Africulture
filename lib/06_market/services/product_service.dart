import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductService extends ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = true;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;

  ProductService() {
    loadProducts();
  }

  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Generate 584 products (skipping 577)
    _products = List.generate(584, (index) {
      final number = index + 1;
      return Product.fromNumber(number);
    }).where((product) => product.id != 577).toList();

    _isLoading = false;
    notifyListeners();
  }

  List<Product> getProductsByCategory(String category) {
    return _products.where((product) => product.category == category).toList();
  }

  List<String> getCategories() {
    return _products.map((product) => product.category).toSet().toList();
  }
}