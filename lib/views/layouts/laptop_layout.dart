import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/cart_provider.dart';
import '../widgets/category_filter_bar.dart';
import '../widgets/product_grid.dart';
import '../widgets/search_bar_widget.dart';

class LaptopLayout extends ConsumerWidget {
  const LaptopLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final totalItems = ref.watch(cartItemCountProvider);
    final totalPrice = ref.watch(cartTotalProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Row(
        children: [
          // Sidebar Navigation / Category Filtering
          Material(
            color: Colors.white,
            child: SizedBox(
              width: 240,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                    child: Row(
                      children: [
                        Icon(Icons.storefront, color: Theme.of(context).colorScheme.primary, size: 28),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'ShopFlow',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Categories',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: CategoryFilterBar(isVertical: true),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const VerticalDivider(width: 1, color: Colors.grey),

          // Main Content Area
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Search Bar Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  color: Colors.white,
                  child: const Row(
                    children: [
                      Expanded(
                        child: SearchBarWidget(),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Product Grid View
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Available Products',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12),
                        Expanded(
                          child: ProductGrid(crossAxisCount: 3),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const VerticalDivider(width: 1, color: Colors.grey),

          // Persistent Cart Sidebar on Laptop View
          Material(
            color: Colors.white,
            child: SizedBox(
              width: 300,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Icon(Icons.shopping_cart, color: Theme.of(context).colorScheme.primary, size: 22),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'Shopping Cart',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          child: Text(
                            '$totalItems',
                            style: const TextStyle(color: Colors.white, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: cartItems.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.remove_shopping_cart, size: 64, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text(
                                  'Your cart is empty',
                                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: cartItems.length,
                            itemBuilder: (context, index) {
                              final item = cartItems[index];
                              return Material(
                                color: Colors.transparent,
                                child: ListTile(
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: item.product.imageUrl.isNotEmpty
                                        ? Image.network(
                                            item.product.imageUrl,
                                            width: 44,
                                            height: 44,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) =>
                                                const Icon(Icons.image, size: 44),
                                          )
                                        : const Icon(Icons.image, size: 44),
                                  ),
                                  title: Text(
                                    item.product.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                  subtitle: Text(
                                    '\$${item.product.price.toStringAsFixed(2)} x ${item.quantity}',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove_circle_outline, size: 18),
                                        onPressed: () {
                                          ref.read(cartProvider.notifier).updateQuantity(
                                                item.product.id,
                                                item.quantity - 1,
                                              );
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.add_circle_outline, size: 18),
                                        onPressed: () {
                                          ref.read(cartProvider.notifier).updateQuantity(
                                                item.product.id,
                                                item.quantity + 1,
                                              );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  const Divider(height: 1),
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total:',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '\$${totalPrice.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: cartItems.isEmpty
                                ? null
                                : () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Checkout Success'),
                                        content: Text(
                                          'Thank you for your purchase! Total: \$${totalPrice.toStringAsFixed(2)}',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              ref.read(cartProvider.notifier).clearCart();
                                              Navigator.pop(context);
                                            },
                                            child: const Text('OK'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                            child: const Text(
                              'Proceed to Checkout',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
