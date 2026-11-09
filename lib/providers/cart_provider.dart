import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addToCart(Product product, {int quantity = 1}) {
    final existingIndex = state.indexWhere((item) => item.product.id == product.id);

    if (existingIndex >= 0) {
      final existingItem = state[existingIndex];
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == existingIndex)
            existingItem.copyWith(quantity: existingItem.quantity + quantity)
          else
            state[i],
      ];
    } else {
      state = [...state, CartItem(product: product, quantity: quantity)];
    }
  }

  void addItem(Product product) {
    addToCart(product);
  }

  void removeFromCart(dynamic productOrId) {
    final String productId = productOrId is Product ? productOrId.id : productOrId.toString();
    final index = state.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      if (productOrId is Product && state[index].quantity > 1) {
        state = [
          for (int i = 0; i < state.length; i++)
            if (i == index)
              state[i].copyWith(quantity: state[i].quantity - 1)
            else
              state[i],
        ];
      } else {
        state = state.where((item) => item.product.id != productId).toList();
      }
    }
  }

  void removeItem(String productId) {
    state = state.where((item) => item.product.id != productId).toList();
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeItem(productId);
      return;
    }

    state = [
      for (final item in state)
        if (item.product.id == productId)
          item.copyWith(quantity: quantity)
        else
          item,
    ];
  }

  void clearCart() {
    state = [];
  }

  double get totalPrice {
    return state.fold<double>(0.0, (acc, item) => acc + item.totalPrice);
  }

  int get totalItems {
    return state.fold<int>(0, (acc, item) => acc + item.quantity);
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

final cartTotalProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold<double>(0.0, (acc, item) => acc + item.totalPrice);
});

final cartItemCountProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold<int>(0, (acc, item) => acc + item.quantity);
});
