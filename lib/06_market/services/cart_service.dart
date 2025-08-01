import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product.dart';
import '../models/cart_item.dart';

class CartService with ChangeNotifier {
  final List<CartItem> _items = [];
  bool _syncing = false;
  String? _error;

  List<CartItem> get items => _items;
  int get itemCount => _items.fold(0, (int sum, item) => sum + item.quantity);
  double get totalPrice => _items.fold(0, (sum, item) => sum + item.totalPrice);
  bool get syncing => _syncing;
  String? get error => _error;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> loadCart() async {
    if (_auth.currentUser == null) return;

    try {
      _syncing = true;
      notifyListeners();

      final snapshot = await _firestore
          .collection('users/${_auth.currentUser!.uid}/cart')
          .get();

      _items.clear();
      for (var doc in snapshot.docs) {
        final product = Product.fromFirestore(doc);
        _items.add(CartItem(
          product: product,
          quantity: doc.data()['quantity'] ?? 1,
        ));
      }
      _error = null;
    } catch (e) {
      _error = 'Failed to load cart: ${e.toString()}';
      debugPrint(_error);
    } finally {
      _syncing = false;
      notifyListeners();
    }
  }

  Future<void> addToCart(Product product, {int quantity = 1}) async {
    if (_auth.currentUser == null) {
      _error = 'You must be logged in to add to cart';
      notifyListeners();
      return;
    }

    if (quantity <= 0 || product.stock < quantity) {
      _error = 'Not enough stock available';
      notifyListeners();
      return;
    }

    try {
      _syncing = true;
      notifyListeners();

      await _firestore
          .collection('users/${_auth.currentUser!.uid}/cart')
          .doc(product.id)
          .set({
        'quantity': FieldValue.increment(quantity),
        'lastUpdated': FieldValue.serverTimestamp(),
        ...product.toMap(),
      }, SetOptions(merge: true));

      final existingIndex = _items.indexWhere((i) => i.product.id == product.id);
      if (existingIndex >= 0) {
        _items[existingIndex].quantity += quantity;
      } else {
        _items.add(CartItem(product: product, quantity: quantity));
      }
      _error = null;
    } catch (e) {
      _error = 'Failed to add to cart: ${e.toString()}';
      debugPrint(_error);
    } finally {
      _syncing = false;
      notifyListeners();
    }
  }

  Future<void> removeFromCart(Product product, {bool completely = false}) async {
    if (_auth.currentUser == null) return;

    try {
      _syncing = true;
      notifyListeners();

      if (completely) {
        await _firestore
            .collection('users/${_auth.currentUser!.uid}/cart')
            .doc(product.id)
            .delete();
        _items.removeWhere((i) => i.product.id == product.id);
      } else {
        await _firestore
            .collection('users/${_auth.currentUser!.uid}/cart')
            .doc(product.id)
            .update({
          'quantity': FieldValue.increment(-1),
          'lastUpdated': FieldValue.serverTimestamp(),
        });

        final index = _items.indexWhere((i) => i.product.id == product.id);
        if (index >= 0) {
          if (_items[index].quantity > 1) {
            _items[index].quantity--;
          } else {
            _items.removeAt(index);
          }
        }
      }
      _error = null;
    } catch (e) {
      _error = 'Failed to update cart: ${e.toString()}';
      debugPrint(_error);
    } finally {
      _syncing = false;
      notifyListeners();
    }
  }

  Future<void> clearCart() async {
    if (_auth.currentUser == null) return;

    try {
      _syncing = true;
      notifyListeners();

      final batch = _firestore.batch();
      final collection = _firestore.collection('users/${_auth.currentUser!.uid}/cart');

      for (var item in _items) {
        batch.delete(collection.doc(item.product.id));
      }

      await batch.commit();
      _items.clear();
      _error = null;
    } catch (e) {
      _error = 'Failed to clear cart: ${e.toString()}';
      debugPrint(_error);
    } finally {
      _syncing = false;
      notifyListeners();
    }
  }
}