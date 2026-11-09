import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/product_provider.dart';

class CategoryFilterBar extends ConsumerWidget {
  final bool isVertical;

  const CategoryFilterBar({super.key, this.isVertical = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return categoriesAsync.when(
      data: (categories) => _buildList(context, ref, categories, selectedCategory),
      loading: () => _buildList(
        context,
        ref,
        const ['All', 'Electronics', 'Accessories', 'Lifestyle'],
        selectedCategory,
      ),
      error: (_, __) => _buildList(
        context,
        ref,
        const ['All', 'Electronics', 'Accessories', 'Lifestyle'],
        selectedCategory,
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    WidgetRef ref,
    List<String> categories,
    String? selectedCategory,
  ) {
    if (isVertical) {
      return ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category ||
              (category == 'All' && (selectedCategory == null || selectedCategory == 'All'));

          return Material(
            color: Colors.transparent,
            child: ListTile(
              title: Text(category),
              selected: isSelected,
              selectedTileColor: Theme.of(context).colorScheme.primaryContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              onTap: () {
                ref.read(selectedCategoryProvider.notifier).state =
                    category == 'All' ? 'All' : category;
              },
            ),
          );
        },
      );
    }

    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category ||
              (category == 'All' && (selectedCategory == null || selectedCategory == 'All'));

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  ref.read(selectedCategoryProvider.notifier).state =
                      category == 'All' ? 'All' : category;
                }
              },
            ),
          );
        },
      ),
    );
  }
}

typedef CategoryFilter = CategoryFilterBar;
