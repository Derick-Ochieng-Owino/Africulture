import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../widgets/product_card.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productService = Provider.of<ProductService>(context);
    final routeArgs = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final categoryFilter = routeArgs?['category'] as String?;

    List<Product> products = categoryFilter != null
        ? productService.getProductsByCategory(categoryFilter)
        : productService.products;

    return Scaffold(
      appBar: AppBar(
        title: categoryFilter != null
            ? Text(categoryFilter)
            : const Text('All Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () {
              _showFilterDialog(context, productService, categoryFilter);
            },
          ),
        ],
      ),
      body: products.isEmpty
          ? const Center(
        child: Text('No products found'),
      )
          : GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return ProductCard(
            product: products[index],
            onTap: () {
              Navigator.pushNamed(
                context,
                '/product_detail',
                arguments: products[index],
              );
            },
          );
        },
      ),
    );
  }

  void _showFilterDialog(
      BuildContext context,
      ProductService productService,
      String? currentCategory,
      ) {
    final categories = productService.getCategories();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filter Products'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: categories.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return ListTile(
                    title: const Text('All Categories'),
                    leading: Radio<String?>(
                      value: null,
                      groupValue: currentCategory,
                      onChanged: (value) {
                        Navigator.pop(context);
                        Navigator.pushReplacementNamed(
                          context,
                          '/products',
                        );
                      },
                    ),
                  );
                }
                final category = categories[index - 1];
                return ListTile(
                  title: Text(category),
                  leading: Radio<String?>(
                    value: category,
                    groupValue: currentCategory,
                    onChanged: (value) {
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(
                        context,
                        '/products',
                        arguments: {'category': value},
                      );
                    },
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}