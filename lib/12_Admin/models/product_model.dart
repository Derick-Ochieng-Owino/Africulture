import 'package:cloud_firestore/cloud_firestore.dart';

class AdminProduct {
  final String id;
  final String name;
  final String description;
  final String category;
  final double price;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final bool approved;
  final List<String> searchKeywords;
  final String sellerId;
  final int stock;
  final DateTime createdAt;

  AdminProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.approved,
    required this.searchKeywords,
    required this.sellerId,
    required this.stock,
    required this.createdAt,
  });

  factory AdminProduct.fromMap(Map<String, dynamic> map, String id) {
    // helper safe parsing
    double _parseDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    int _parseInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString()) ?? 0;
    }

    DateTime _parseDate(dynamic v) {
      if (v == null) return DateTime.now();
      if (v is Timestamp) return (v).toDate();
      if (v is DateTime) return v;
      return DateTime.tryParse(v.toString()) ?? DateTime.now();
    }

    final keywords = (map['searchKeywords'] as List<dynamic>?)
        ?.map((e) => e?.toString() ?? '')
        .where((s) => s.isNotEmpty)
        .toList() ??
        <String>[];

    return AdminProduct(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      price: _parseDouble(map['price']),
      imageUrl: map['imageUrl'] ?? '',
      rating: _parseDouble(map['rating']),
      reviewCount: _parseInt(map['reviewCount']),
      approved: map['approved'] == true,
      searchKeywords: keywords,
      sellerId: map['sellerId'] ?? '',
      stock: _parseInt(map['stock']),
      createdAt: _parseDate(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'imageUrl': imageUrl,
      'rating': rating,
      'reviewCount': reviewCount,
      'approved': approved,
      'searchKeywords': searchKeywords,
      'sellerId': sellerId,
      'stock': stock,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  AdminProduct copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    double? price,
    String? imageUrl,
    double? rating,
    int? reviewCount,
    bool? approved,
    List<String>? searchKeywords,
    String? sellerId,
    int? stock,
    DateTime? createdAt,
  }) {
    return AdminProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      approved: approved ?? this.approved,
      searchKeywords: searchKeywords ?? this.searchKeywords,
      sellerId: sellerId ?? this.sellerId,
      stock: stock ?? this.stock,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
