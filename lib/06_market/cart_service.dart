import 'package:africulture/06_market/product.dart';

class CartService {
  static final List<Product> _cartItems = [];

  static void addToCart(Product product) => _cartItems.add(product);

  static void removeFromCart(String productId) =>
      _cartItems.removeWhere((item) => item.id == productId);

  static List<Product> getCartItems() => List.unmodifiable(_cartItems);

  static double getTotalPrice() =>
      _cartItems.fold(0, (sum, item) => sum + item.price);
}
