class Product {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final String description;
  final String category;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.description,
    required this.category,
  });

  factory Product.fromMap(String id, Map<String, dynamic> data) {
    return Product(
      id: id,
      name: data['name'],
      price: data['price'].toDouble(),
      imageUrl: data['imageUrl'],
      description: data['description'] ?? '',
      category: data['category'] ?? 'Others',
    );
  }
}
