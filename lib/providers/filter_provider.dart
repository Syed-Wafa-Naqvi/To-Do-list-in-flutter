import 'package:flutter_riverpod/flutter_riverpod.dart';

class FilterState {
  final String searchQuery;
  final String selectedCategory;

  const FilterState({
    this.searchQuery = '',
    this.selectedCategory = 'All',
  });

  FilterState copyWith({
    String? searchQuery,
    String? selectedCategory,
  }) {
    return FilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }
}

class FilterNotifier extends StateNotifier<FilterState> {
  FilterNotifier() : super(const FilterState());

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setSelectedCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }

  void resetFilters() {
    state = const FilterState();
  }
}

final filterProvider = StateNotifierProvider<FilterNotifier, FilterState>((ref) {
  return FilterNotifier();
});