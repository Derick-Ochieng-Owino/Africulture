import 'package:flutter/material.dart';
import 'package:africulture/service/cart_service.dart';
import 'package:africulture/models/product.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    final cartItems = CartService.getCartItems();

    return Scaffold(
      appBar: AppBar(title: const Text("Your Cart")),
      body: cartItems.isEmpty
          ? const Center(child: Text("Your cart is empty"))
          : ListView.builder(
        itemCount: cartItems.length,
        itemBuilder: (context, index) {
          final product = cartItems[index];
          return ListTile(
            leading: Image.network(product.imageUrl, width: 50),
            title: Text(product.name),
            subtitle: Text("KES ${product.price}"),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                setState(() {
                  CartService.removeFromCart(product.id);
                });
              },
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(12),
        color: Colors.green,
        child: Text(
          "Total: KES ${CartService.getTotalPrice().toStringAsFixed(2)}",
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}
