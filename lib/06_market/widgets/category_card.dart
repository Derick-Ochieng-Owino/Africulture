import 'package:flutter/material.dart';

class CategoryCard extends StatelessWidget {
  final String category;
  final int productCount;

  const CategoryCard({
    super.key,
    required this.category,
    required this.productCount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/products',
            arguments: {'category': category},
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getCategoryIcon(category),
                size: 36,
                color: Colors.green[700],
              ),
              const SizedBox(height: 8),
              Text(
                category,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                '$productCount items',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'seeds':
        return Icons.grass;
      case 'fertilizers':
        return Icons.eco;
      case 'pesticides':
        return Icons.bug_report;
      case 'equipment':
        return Icons.agriculture;
      case 'tools':
        return Icons.build;
      case 'irrigation':
        return Icons.water_drop;
      case 'organic':
        return Icons.spa;
      case 'livestock':
        return Icons.pets;
      case 'feed':
        return Icons.fastfood;
      default:
        return Icons.category;
    }
  }
}