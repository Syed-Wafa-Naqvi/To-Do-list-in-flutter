import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../models/cart_item_model.dart';

class FirestoreService {
  FirebaseFirestore? get _db {
    try {
      return FirebaseFirestore.instance;
    } catch (e) {
      debugPrint('Firestore instance not available: $e');
      return null;
    }
  }

  static List<Product> get fallbackProducts => [
    const Product(
      id: '1',
      name: 'Wireless Ergonomic Mouse',
      category: 'Electronics',
      price: 49.99,
      imageUrl: 'https://images.unsplash.com/photo-1615663245857-ac93bb7c39e7?w=500',
      description: 'Comfortable wireless mouse with customizable buttons and long battery life.',
      rating: 4.5,
      stock: 25,
    ),
    const Product(
      id: '2',
      name: 'Mechanical Gaming Keyboard',
      category: 'Electronics',
      price: 89.99,
      imageUrl: 'https://images.unsplash.com/photo-1587829741301-dc798b83add3?w=500',
      description: 'RGB backlit mechanical keyboard with tactile switches for high performance.',
      rating: 4.8,
      stock: 14,
    ),
    const Product(
      id: '3',
      name: 'Minimalist Leather Backpack',
      category: 'Accessories',
      price: 120.00,
      imageUrl: 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=500',
      description: 'Durable and sleek leather backpack suitable for laptops and daily commutes.',
      rating: 4.6,
      stock: 10,
    ),
    const Product(
      id: '4',
      name: 'Stainless Steel Water Bottle',
      category: 'Lifestyle',
      price: 24.50,
      imageUrl: 'https://images.unsplash.com/photo-1602143407151-7111542de6e8?w=500',
      description: 'Double-walled insulated water bottle keeps drinks cold for 24 hours.',
      rating: 4.3,
      stock: 50,
    ),
    const Product(
      id: '5',
      name: 'Noise-Canceling Headphones',
      category: 'Electronics',
      price: 199.99,
      imageUrl: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=500',
      description: 'Immersive sound quality with active noise cancellation and plush earcups.',
      rating: 4.9,
      stock: 8,
    ),
  ];

  // Fetch all products or filter by category and search query
  Stream<List<Product>> getProducts({String? category, String? searchQuery}) {
    final db = _db;
    if (db == null) {
      return Stream.value(_filterLocalProducts(fallbackProducts, category, searchQuery));
    }

    try {
      Query query = db.collection('products');
      if (category != null && category != 'All') {
        query = query.where('category', isEqualTo: category);
      }

      return query.snapshots().map((snapshot) {
        if (snapshot.docs.isEmpty) {
          return _filterLocalProducts(fallbackProducts, category, searchQuery);
        }
        var products = snapshot.docs
            .map((doc) => Product.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList();

        if (searchQuery != null && searchQuery.trim().isNotEmpty) {
          final queryLower = searchQuery.toLowerCase();
          products = products.where((product) {
            final titleLower = product.name.toLowerCase();
            final descLower = product.description.toLowerCase();
            return titleLower.contains(queryLower) || descLower.contains(queryLower);
          }).toList();
        }

        return products;
      }).handleError((error) {
        debugPrint('Firestore query error: $error, falling back to local products');
        return _filterLocalProducts(fallbackProducts, category, searchQuery);
      });
    } catch (e) {
      return Stream.value(_filterLocalProducts(fallbackProducts, category, searchQuery));
    }
  }

  List<Product> _filterLocalProducts(List<Product> list, String? category, String? searchQuery) {
    return list.where((product) {
      final matchesCategory = category == null ||
          category == 'All' ||
          product.category.toLowerCase() == category.toLowerCase();
      final matchesSearch = searchQuery == null ||
          searchQuery.trim().isEmpty ||
          product.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          product.description.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  // Fetch unique categories
  Stream<List<String>> getCategories() {
    final db = _db;
    if (db == null) {
      return Stream.value(['All', 'Electronics', 'Accessories', 'Lifestyle']);
    }

    try {
      return db.collection('products').snapshots().map((snapshot) {
        if (snapshot.docs.isEmpty) {
          return ['All', 'Electronics', 'Accessories', 'Lifestyle'];
        }
        final categories = snapshot.docs
            .map((doc) => (doc.data())['category'] as String?)
            .where((category) => category != null && category.isNotEmpty)
            .cast<String>()
            .toSet()
            .toList();
        categories.sort();
        return ['All', ...categories];
      }).handleError((_) => ['All', 'Electronics', 'Accessories', 'Lifestyle']);
    } catch (_) {
      return Stream.value(['All', 'Electronics', 'Accessories', 'Lifestyle']);
    }
  }

  // Cart Management
  Stream<List<CartItem>> getCartItems(String cartId) {
    final db = _db;
    if (db == null) return Stream.value([]);
    try {
      return db
          .collection('carts')
          .doc(cartId)
          .collection('items')
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => CartItem.fromFirestore(doc.data(), doc.id))
            .toList();
      }).handleError((_) => <CartItem>[]);
    } catch (_) {
      return Stream.value([]);
    }
  }

  Future<void> addToCart(String cartId, Product product, {int quantity = 1}) async {
    final db = _db;
    if (db == null) return;
    try {
      final cartRef = db.collection('carts').doc(cartId).collection('items');
      final existingQuery = await cartRef.where('productId', isEqualTo: product.id).get();

      if (existingQuery.docs.isNotEmpty) {
        final docId = existingQuery.docs.first.id;
        final currentQty = (existingQuery.docs.first.data()['quantity'] as num).toInt();
        await cartRef.doc(docId).update({'quantity': currentQty + quantity});
      } else {
        await cartRef.add({
          'productId': product.id,
          'name': product.name,
          'price': product.price,
          'imageUrl': product.imageUrl,
          'category': product.category,
          'quantity': quantity,
        });
      }
    } catch (e) {
      debugPrint('Error adding to firestore cart: $e');
    }
  }

  Future<void> updateCartItemQuantity(String cartId, String cartItemId, int quantity) async {
    final db = _db;
    if (db == null) return;
    try {
      final itemRef = db.collection('carts').doc(cartId).collection('items').doc(cartItemId);
      if (quantity <= 0) {
        await itemRef.delete();
      } else {
        await itemRef.update({'quantity': quantity});
      }
    } catch (e) {
      debugPrint('Error updating firestore cart item: $e');
    }
  }

  Future<void> removeFromCart(String cartId, String cartItemId) async {
    final db = _db;
    if (db == null) return;
    try {
      await db.collection('carts').doc(cartId).collection('items').doc(cartItemId).delete();
    } catch (e) {
      debugPrint('Error removing from firestore cart: $e');
    }
  }

  Future<void> clearCart(String cartId) async {
    final db = _db;
    if (db == null) return;
    try {
      final itemsSnapshot = await db.collection('carts').doc(cartId).collection('items').get();
      for (var doc in itemsSnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      debugPrint('Error clearing firestore cart: $e');
    }
  }
}
