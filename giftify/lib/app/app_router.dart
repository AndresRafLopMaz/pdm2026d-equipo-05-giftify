import 'package:flutter/material.dart';

import '../features/auth/screens/register_screen.dart';
import '../features/cart/screens/cart_screen.dart';
import '../features/cart/screens/checkout_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/products/screens/product_detail_screen.dart';
import '../features/products/screens/product_results_screen.dart';
import '../features/search/screens/gift_search_screen.dart';

/// Nombres centralizados de las rutas de Giftify.
///
/// Ningún módulo debería escribir manualmente cadenas como "/cart"
/// o "/checkout". Se deben utilizar estas constantes.
abstract final class AppRoutes {
  static const String register = '/register';
  static const String home = '/home';
  static const String search = '/search';
  static const String productResults = '/products';
  static const String productDetail = '/products/detail';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
}

/// Router central de la aplicación.
///
/// Más adelante permitirá recibir argumentos entre pantallas,
/// por ejemplo un producto seleccionado o los criterios de búsqueda.
abstract final class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.register:
        return MaterialPageRoute(
          builder: (_) => const RegisterScreen(),
          settings: settings,
        );

      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );

      case AppRoutes.search:
        return MaterialPageRoute(
          builder: (_) => const GiftSearchScreen(),
          settings: settings,
        );

      case AppRoutes.productResults:
        return MaterialPageRoute(
          builder: (_) => const ProductResultsScreen(),
          settings: settings,
        );

      case AppRoutes.productDetail:
        return MaterialPageRoute(
          builder: (_) => const ProductDetailScreen(),
          settings: settings,
        );

      case AppRoutes.cart:
        return MaterialPageRoute(
          builder: (_) => const CartScreen(),
          settings: settings,
        );

      case AppRoutes.checkout:
        return MaterialPageRoute(
          builder: (_) => const CheckoutScreen(),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Ruta no encontrada'))),
          settings: settings,
        );
    }
  }
}
