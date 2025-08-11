import 'package:africulture/06_market/models/product.dart';

class CartItem {
  final MarketProduct product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  double get totalPrice => product.price * quantity;
}

