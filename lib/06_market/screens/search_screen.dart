// lib/screens/search_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../widgets/product_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Product> _searchResults = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchProducts(String query) {
    final productService = Provider.of<ProductService>(context, listen: false);
    setState(() {
      _searchResults = productService.products
          .where((product) =>
      product.name.toLowerCase().contains(query.toLowerCase()) ||
          product.category.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search for agricultural products...',
            border: InputBorder.none,
          ),
          autofocus: true,
          onChanged: _searchProducts,
        ),
      ),
      body: _searchController.text.isEmpty
          ? const Center(
        child: Text('Enter a search term to find products'),
      )
          : GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        padding: const EdgeInsets.all(8),
        children: _searchResults
            .map(
              (product) => ProductCard(
            product: product,
            onTap: () {
              Navigator.pushNamed(
                context,
                '/product_detail',
                arguments: product,
              );
            },
          ),
        )
            .toList(),
      ),
    );
  }
}