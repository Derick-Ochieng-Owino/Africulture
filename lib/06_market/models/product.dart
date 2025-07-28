class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final String category;
  final int stock;
  final String imagePath;

  // Private constructor
  Product._({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.stock,
    required this.imagePath,
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

    final category = categories[number % categories.length];
    final imagePath = _getImagePath(number, category.toLowerCase());

    return Product._(
      id: number,
      name: 'Agricultural Product $number',
      description: 'High-quality agricultural product suitable for various farming needs. '
          'This item is part of our premium collection for professional farmers.',
      price: (number % 50 + 1) * 10.0,
      category: category,
      stock: number % 100,
      imagePath: imagePath,
    );
  }

  static String _getImagePath(int id, String category) {
    final Map<String, List<String>> categoryImages = {
      'seeds': ['maize', 'beans', 'cabbage', 'wheat', 'rice'],
      'fertilizers': ['organic', 'chemical'],
      'equipment': ['tractor', 'plow'],
      'pesticides': ['sprayer', 'herbicide'],
      'tools': ['shovel', 'rake', 'hoe'],
      'irrigation': ['sprinkler', 'hose'],
      // 'organic': ['compost', 'manure'],
      // 'livestock': ['cow', 'chicken', 'goat'],
      // 'feed': ['poultry', 'cattle', 'pig'],
      // 'accessories': ['gloves', 'boots']
    };

    final images = categoryImages[category] ?? ['default'];
    final imageName = images[id % images.length];

    return 'assets/products/$category/$imageName.jpg';
  }
}