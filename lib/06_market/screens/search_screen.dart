import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/product_service.dart';
import '../widgets/product_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productService = Provider.of<ProductService>(context);
    final List products = _isSearching
        ? productService.searchResults
        : productService.products;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search for agricultural products...',
            border: InputBorder.none,
            suffixIcon: _isSearching
                ? IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                _searchController.clear();
                productService.clearSearch();
                setState(() => _isSearching = false);
              },
            )
                : null,
          ),
          autofocus: true,
          onChanged: (query) {
            if (query.isNotEmpty) {
              setState(() => _isSearching = true);
              productService.searchProducts(query);
            } else {
              setState(() => _isSearching = false);
              productService.clearSearch();
            }
          },
        ),
      ),
      body: Builder(
        builder: (context) {
          if (productService.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (products.isEmpty) {
            return const Center(
              child: Text('No products found'),
            );
          }

          return GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            padding: const EdgeInsets.all(8),
            children: products.map(
                  (product) => ProductCard(
                product: product,
                onTap: () => Navigator.pushNamed(
                  context,
                  '/product_detail',
                  arguments: product,
                ),
              ),
            ).toList(),
          );
        },
      ),
    );
  }
}
