import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/product_service.dart';
import '../widgets/bottom_navbar.dart';
import '../widgets/category_card.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      final productService = Provider.of<ProductService>(context, listen: false);
      if (productService.products.isEmpty) {
        productService.loadProducts();
      }
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final productService = Provider.of<ProductService>(context);
    final categories = productService.getCategories();

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Categories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.pushNamed(context, '/search'),
          ),
        ],
      ),
      body: productService.isLoading
          ? const Center(child: CircularProgressIndicator())
          : categories.isEmpty
          ? const Center(child: Text('No categories found.'))
          : GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final products = productService.getProductsByCategory(category);

          return CategoryCard(
            category: category,
            productCount: products.length,
            onTap: () => Navigator.pushNamed(
              context,
              '/products',
              arguments: {'category': category},
            ),
          );
        },
      ),
      bottomNavigationBar: const BottomNavBar(selectedIndex: 1),
    );
  }
}
