import 'package:flutter/material.dart';
import 'package:africulture/06_market/product.dart';
import 'package:africulture/06_market/cart_service.dart';

class ProductDetailPage extends StatelessWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: Column(
        children: [
          Image.network(product.imageUrl),
          const SizedBox(height: 12),
          Text(product.name, style: const TextStyle(fontSize: 22)),
          Text("KES ${product.price}", style: const TextStyle(fontSize: 18)),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(product.description),
          ),
          ElevatedButton(
            onPressed: () {
              CartService.addToCart(product);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Added to cart")),
              );
            },
            child: const Text("Add to Cart"),
          ),
        ],
      ),
    );
  }
}
