import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:product_listing_prototype/models/product_model.dart';
import 'package:product_listing_prototype/models/cart_item_model.dart';
import 'package:product_listing_prototype/providers/cart_provider.dart';

void main() {
  group('CartNotifier and Cart Providers', () {
    const productA = Product(
      id: 'p1',
      name: 'Test Product 1',
      description: 'Description 1',
      price: 25.0,
      imageUrl: '',
      category: 'Electronics',
    );

    const productB = Product(
      id: 'p2',
      name: 'Test Product 2',
      description: 'Description 2',
      price: 15.0,
      imageUrl: '',
      category: 'Accessories',
    );

    test('Initial cart state is empty', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(cartProvider), isEmpty);
      expect(container.read(cartTotalProvider), 0.0);
      expect(container.read(cartItemCountProvider), 0);
    });

    test('Adding product adds it with quantity 1', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(cartProvider.notifier).addToCart(productA);

      final items = container.read(cartProvider);
      expect(items.length, 1);
      expect(items.first.product.id, 'p1');
      expect(items.first.quantity, 1);
      expect(container.read(cartTotalProvider), 25.0);
      expect(container.read(cartItemCountProvider), 1);
    });

    test('Adding same product increments quantity', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(cartProvider.notifier).addToCart(productA);
      container.read(cartProvider.notifier).addToCart(productA);

      final items = container.read(cartProvider);
      expect(items.length, 1);
      expect(items.first.quantity, 2);
      expect(container.read(cartTotalProvider), 50.0);
      expect(container.read(cartItemCountProvider), 2);
    });

    test('Adding multiple distinct products updates totals correctly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(cartProvider.notifier).addToCart(productA);
      container.read(cartProvider.notifier).addToCart(productB, quantity: 2);

      final items = container.read(cartProvider);
      expect(items.length, 2);
      expect(container.read(cartTotalProvider), 55.0);
      expect(container.read(cartItemCountProvider), 3);
    });

    test('updateQuantity modifies quantity or removes item when 0', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(cartProvider.notifier).addToCart(productA, quantity: 3);
      container.read(cartProvider.notifier).updateQuantity('p1', 5);

      expect(container.read(cartProvider).first.quantity, 5);
      expect(container.read(cartTotalProvider), 125.0);

      container.read(cartProvider.notifier).updateQuantity('p1', 0);
      expect(container.read(cartProvider), isEmpty);
    });

    test('removeFromCart and clearCart work as expected', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(cartProvider.notifier).addToCart(productA);
      container.read(cartProvider.notifier).addToCart(productB);

      container.read(cartProvider.notifier).removeFromCart('p1');
      expect(container.read(cartProvider).length, 1);
      expect(container.read(cartProvider).first.product.id, 'p2');

      container.read(cartProvider.notifier).clearCart();
      expect(container.read(cartProvider), isEmpty);
    });
  });

  group('ProductModel & CartItemModel', () {
    test('Product serialization and getters', () {
      final json = {
        'id': 'test-1',
        'title': 'Sample Item',
        'description': 'A sample product description',
        'price': 19.99,
        'imageUrl': 'https://example.com/item.jpg',
        'category': 'Lifestyle',
        'rating': 4.7,
        'stock': 12,
      };

      final product = Product.fromMap(json);
      expect(product.id, 'test-1');
      expect(product.name, 'Sample Item');
      expect(product.title, 'Sample Item');
      expect(product.price, 19.99);
      expect(product.stock, 12);

      final mapped = product.toMap();
      expect(mapped['name'], 'Sample Item');
      expect(mapped['price'], 19.99);
    });

    test('CartItem getters and serialization', () {
      const product = Product(
        id: 'p10',
        name: 'Desk Lamp',
        description: 'LED Lamp',
        price: 30.0,
        imageUrl: 'https://example.com/lamp.jpg',
        category: 'Home',
      );

      const cartItem = CartItem(product: product, quantity: 3);
      expect(cartItem.productId, 'p10');
      expect(cartItem.productName, 'Desk Lamp');
      expect(cartItem.title, 'Desk Lamp');
      expect(cartItem.price, 30.0);
      expect(cartItem.totalPrice, 90.0);
    });
  });
}
