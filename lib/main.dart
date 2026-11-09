import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'views/layouts/responsive_layout.dart';
import 'views/layouts/mobile_layout.dart';
import 'views/layouts/laptop_layout.dart';
import 'views/screens/catalog_screen.dart';
import 'views/screens/cart_screen.dart';

// Re-exports for project-wide convenience and backward compatibility
export 'models/product_model.dart';
export 'models/cart_item_model.dart';
export 'providers/product_provider.dart';
export 'providers/cart_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization notice: $e');
  }
  runApp(
    const ProviderScope(
      child: ProductCatalogApp(),
    ),
  );
}

class ProductCatalogApp extends StatelessWidget {
  const ProductCatalogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Storefront Prototype',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const ResponsiveLayout(
              mobileBody: MobileLayout(),
              desktopBody: LaptopLayout(),
            ),
        '/catalog': (context) => const CatalogScreen(),
        '/cart': (context) => const CartScreen(),
      },
    );
  }
}

typedef MyApp = ProductCatalogApp;
