import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product_model.dart';
import '../services/firestore_service.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedCategoryProvider = StateProvider<String?>((ref) => 'All');

final categoriesProvider = StreamProvider<List<String>>((ref) {
  final service = ref.watch(firestoreServiceProvider);
  return service.getCategories();
});

final productStreamProvider = StreamProvider<List<Product>>((ref) {
  final service = ref.watch(firestoreServiceProvider);
  return service.getProducts();
});

final productsProvider = productStreamProvider;

final filteredProductsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  final productAsync = ref.watch(productStreamProvider);
  final searchQuery = ref.watch(searchQueryProvider).trim().toLowerCase();
  final selectedCategory = ref.watch(selectedCategoryProvider);

  return productAsync.whenData((products) {
    return products.where((product) {
      final matchesSearch = searchQuery.isEmpty ||
          product.name.toLowerCase().contains(searchQuery) ||
          product.description.toLowerCase().contains(searchQuery);

      final matchesCategory = selectedCategory == null ||
          selectedCategory == 'All' ||
          product.category.toLowerCase() == selectedCategory.toLowerCase();

      return matchesSearch && matchesCategory;
    }).toList();
  });
});
