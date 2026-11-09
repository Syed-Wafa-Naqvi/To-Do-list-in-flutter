import 'product_model.dart';

typedef CartItemModel = CartItem;

class CartItem {
  final Product product;
  final int quantity;

  const CartItem({
    required this.product,
    this.quantity = 1,
  });

  double get totalPrice => product.price * quantity;
  double get price => product.price;
  String get productId => product.id;
  String get title => product.name;
  String get productName => product.name;
  String get imageUrl => product.imageUrl;
  String get category => product.category;

  CartItem copyWith({
    Product? product,
    int? quantity,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': product.id,
      'product': product.toMap(),
      'quantity': quantity,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map, {Product? product}) {
    final prod = product ??
        (map['product'] is Map<String, dynamic>
            ? Product.fromMap(map['product'] as Map<String, dynamic>)
            : Product.fromMap(map, map['productId'] as String?));
    return CartItem(
      product: prod,
      quantity: ((map['quantity'] ?? 1) as num).toInt(),
    );
  }

  factory CartItem.fromFirestore(Map<String, dynamic> data, String id) {
    return CartItem(
      product: Product(
        id: (data['productId'] ?? id) as String,
        name: (data['name'] ?? data['title'] ?? '') as String,
        description: (data['description'] ?? '') as String,
        price: ((data['price'] ?? 0.0) as num).toDouble(),
        imageUrl: (data['imageUrl'] ?? '') as String,
        category: (data['category'] ?? 'All') as String,
        rating: ((data['rating'] ?? 0.0) as num).toDouble(),
        stock: ((data['stock'] ?? 0) as num).toInt(),
      ),
      quantity: ((data['quantity'] ?? 1) as num).toInt(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItem &&
          runtimeType == other.runtimeType &&
          product.id == other.product.id;

  @override
  int get hashCode => product.id.hashCode;
}
