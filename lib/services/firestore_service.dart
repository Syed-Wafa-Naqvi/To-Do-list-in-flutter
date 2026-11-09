import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import '../models/cart_item.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Fetch all products or filter by category and search query
  Stream<List<Product>> getProducts({String? category, String? searchQuery}) {
    Query query = _db.collection('products');

    if (category != null && category != 'All') {
      query = query.where('category', isEqualTo: category);
    }

    return query.snapshots().map((snapshot) {
      var products = snapshot.docs
          .map((doc) => Product.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      // Client-side filtering for search query to ensure case-insensitive partial matching
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final queryLower = searchQuery.toLowerCase();
        products = products.where((product) {
          final titleLower = product.title.toLowerCase();
          final descLower = product.description.toLowerCase();
          return titleLower.contains(queryLower) || descLower.contains(queryLower);
        }).toList();
      }

      return products;
    });
  }

  // Fetch unique categories
  Stream<List<String>> getCategories() {
    return _db.collection('products').snapshots().map((snapshot) {
      final categories = snapshot.docs
          .map((doc) => (doc.data())['category'] as String?)
          .where((category) => category != null)
          .cast<String>()
          .toSet()
          .toList();
      categories.sort();
      return ['All', ...categories];
    });
  }

  // Cart Management (using a generic device/session cart collection in Firestore)
  // For frictionless anonymous browsing, we use a default cart ID or pass a session identifier.
  Stream<List<CartItem>> getCartItems(String cartId) {
    return _db
        .collection('carts')
        .doc(cartId)
        .collection('items')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => CartItem.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> addToCart(String cartId, Product product, {int quantity = 1}) async {
    final cartRef = _db.collection('carts').doc(cartId).collection('items');
    
    // Check if product already exists in cart
    final existingQuery = await cartRef.where('productId', isEqualTo: product.id).get();

    if (existingQuery.docs.isNotEmpty) {
      final docId = existingQuery.docs.first.id;
      final currentQty = (existingQuery.docs.first.data()['quantity'] as num).toInt();
      await cartRef.doc(docId).update({'quantity': currentQty + quantity});
    } else {
      await cartRef.add({
        'productId': product.id,
        'title': product.title,
        'price': product.price,
        'imageUrl': product.imageUrl,
        'quantity': quantity,
      });
    }
  }

  Future<void> updateCartItemQuantity(String cartId, String cartItemId, int quantity) async {
    final itemRef = _db.collection('carts').doc(cartId).collection('items').doc(cartItemId);
    if (quantity <= 0) {
      await itemRef.delete();
    } else {
      await itemRef.update({'quantity': quantity});
    }
  }

  Future<void> removeFromCart(String cartId, String cartItemId) async {
    await _db.collection('carts').doc(cartId).collection('items').doc(cartItemId).delete();
  }

  Future<void> clearCart(String cartId) async {
    final itemsSnapshot = await _db.collection('carts').doc(cartId).collection('items').get();
    for (var doc in itemsSnapshot.docs) {
      await doc.reference.delete();
    }
  }
}