import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/product_provider.dart';
import 'product_card.dart';

class ProductGrid extends ConsumerWidget {
  final int crossAxisCount;

  const ProductGrid({super.key, required this.crossAxisCount});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(filteredProductsProvider);

    return productsAsync.when(
      data: (products) {
        if (products.isEmpty) {
          return const Center(
            child: Text('No products found.'),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(12.0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.72,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            return ProductCard(product: products[index]);
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stackTrace) => Center(
        child: Text('Error: $error'),
      ),
    );
  }
}

