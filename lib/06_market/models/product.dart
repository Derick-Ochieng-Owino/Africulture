// lib/models/product.dart
class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final String category;
  final String imageUrl;
  final int stock;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrl,
    required this.stock,
  });

  factory Product.fromNumber(int number) {
    final categories = [
      'Seeds',
      'Fertilizers',
      'Pesticides',
      'Equipment',
      'Tools',
      'Irrigation',
      'Organic',
      'Livestock',
      'Feed',
      'Accessories'
    ];

    return Product(
      id: number,
      name: 'Agricultural Product $number',
      description: 'High-quality agricultural product suitable for various farming needs. '
          'This item is part of our premium collection for professional farmers.',
      price: (number % 50 + 1) * 10.0,
      category: categories[number % categories.length],
      imageUrl: 'https://source.unsplash.com/random/300x300/?agriculture,$number',
      stock: number % 100,
    );
  }
}