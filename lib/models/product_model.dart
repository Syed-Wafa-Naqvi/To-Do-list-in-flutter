import 'package:cloud_firestore/cloud_firestore.dart';

typedef ProductModel = Product;

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final double rating;
  final int stock;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.rating = 0.0,
    this.stock = 0,
  });

  String get title => name;

  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};
    return Product.fromMap(data, doc.id);
  }

  factory Product.fromMap(Map<String, dynamic> data, [String? id]) {
    return Product(
      id: id ?? (data['id'] as String?) ?? '',
      name: (data['name'] ?? data['title'] ?? '') as String,
      description: (data['description'] ?? '') as String,
      price: ((data['price'] ?? 0.0) as num).toDouble(),
      imageUrl: (data['imageUrl'] ?? data['image'] ?? 'https://via.placeholder.com/150') as String,
      category: (data['category'] ?? 'All') as String,
      rating: ((data['rating'] ?? 0.0) as num).toDouble(),
      stock: ((data['stock'] ?? 0) as num).toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'rating': rating,
      'stock': stock,
    };
  }

  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    String? category,
    double? rating,
    int? stock,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      rating: rating ?? this.rating,
      stock: stock ?? this.stock,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
