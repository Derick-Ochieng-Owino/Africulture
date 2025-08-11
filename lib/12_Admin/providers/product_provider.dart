import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/product_model.dart';

class ProductProvider with ChangeNotifier {
  List<AdminProduct> _products = [];
  AdminProduct? _selectedProduct;
  bool _isLoading = false;

  List<AdminProduct> get products => _products;
  AdminProduct? get selectedProduct => _selectedProduct;
  bool get isLoading => _isLoading;

  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('products')
          .get();

      // Convert to model list
      _products = snapshot.docs.map((doc) {
        return AdminProduct.fromMap(
          doc.data(),
          doc.id,
        );
      }).toList();

    } catch (e) {
      debugPrint('Error loading products: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  void selectProduct(AdminProduct product) {
    _selectedProduct = product;
    notifyListeners();
  }

  void addProduct(AdminProduct product) {
    _products.add(product);
    notifyListeners();
  }

  void updateProduct(AdminProduct product) {
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products[index] = product;
      notifyListeners();
    }
  }

  void deleteProduct(String productId) {
    _products.removeWhere((p) => p.id == productId);
    notifyListeners();
  }
}