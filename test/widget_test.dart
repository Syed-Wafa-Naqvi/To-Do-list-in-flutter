import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:product_listing_prototype/main.dart';

void main() {
  testWidgets('Product catalog app loads and renders products', (WidgetTester tester) async {
    // Set a tablet/desktop screen size to verify responsive rendering
    tester.view.physicalSize = const Size(1024, 768);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const ProviderScope(
        child: ProductCatalogApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify main components are present
    expect(find.text('ShopFlow'), findsOneWidget);
    expect(find.text('Available Products'), findsOneWidget);
    expect(find.text('Shopping Cart'), findsOneWidget);
    expect(find.text('Your cart is empty'), findsOneWidget);

    // Verify default fallback products are displayed
    expect(find.text('Wireless Ergonomic Mouse'), findsOneWidget);
    expect(find.text('Mechanical Gaming Keyboard'), findsOneWidget);
  });

  testWidgets('Adding product to cart updates cart and total', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1024, 768);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const ProviderScope(
        child: ProductCatalogApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Find and tap the first "Add to Cart" button
    final addToCartButtons = find.widgetWithText(ElevatedButton, 'Add to Cart');
    expect(addToCartButtons, findsWidgets);

    await tester.tap(addToCartButtons.first);
    await tester.pumpAndSettle();

    // Verify cart is no longer empty and item appears in cart panel
    expect(find.text('Your cart is empty'), findsNothing);
    expect(find.text('Proceed to Checkout'), findsOneWidget);
  });

  testWidgets('Mobile view renders navigation and catalog', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const ProviderScope(
        child: ProductCatalogApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Bottom navigation should be visible on mobile
    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.text('Catalog'), findsOneWidget);
    expect(find.text('Cart'), findsOneWidget);
  });
}
