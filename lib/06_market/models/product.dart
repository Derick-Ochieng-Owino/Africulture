import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class MarketProduct {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final String imageUrl;
  final int stock;
  final bool approved;
  final String sellerId;
  final DateTime createdAt;
  final double? rating;
  final int? reviewCount;

  MarketProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrl,
    required this.stock,
    required this.sellerId,
    required this.createdAt,
    this.approved = false,
    this.rating,
    this.reviewCount,
  });

  factory MarketProduct.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return MarketProduct(
      id: doc.id,
      name: data['name'] ?? 'Unnamed Product',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      category: data['category'] ?? 'Uncategorized',
      imageUrl: data['imageUrl'] ?? '',
      stock: data['stock'] ?? 0,
      approved: data['approved'] ?? false,
      sellerId: data['sellerId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      rating: (data['rating'] ?? 0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'imageUrl': imageUrl,
      'stock': stock,
      'approved': approved,
      'sellerId': sellerId,
      'createdAt': Timestamp.fromDate(createdAt),
      'rating': rating,
      'reviewCount': reviewCount,
    };
  }

  String get formattedDate {
    return DateFormat('MMM d, y').format(createdAt);
  }

  String get priceFormatted {
    return NumberFormat.currency(symbol: '\$').format(price);
  }

  bool get isAvailable => stock > 0;
  bool get isLowStock => stock > 0 && stock < 10;
}