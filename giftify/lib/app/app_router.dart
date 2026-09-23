import 'package:flutter/material.dart';

import '../features/auth/screens/register_screen.dart';
import '../features/cart/screens/cart_screen.dart';
import '../features/cart/screens/checkout_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/products/screens/product_detail_screen.dart';
import '../features/products/screens/product_results_screen.dart';
import '../features/search/screens/gift_search_screen.dart';
import '../shared/models/cart_item.dart';
import '../shared/models/gift_product.dart';
import '../shared/models/gift_search_criteria.dart';

/// Nombres centralizados de las rutas de Giftify.
///
/// Se deben utilizar estas constantes en lugar de escribir
/// manualmente rutas como "/cart" o "/products".
abstract final class AppRoutes {
  static const String register = '/register';
  static const String home = '/home';
  static const String search = '/search';
  static const String productResults = '/products';
  static const String productDetail = '/products/detail';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
}

/// Router central de Giftify.
///
/// Todas las pantallas utilizan esta configuración para evitar
/// que cada módulo implemente un sistema de navegación diferente.
abstract final class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.register:
        return _buildRoute(settings, const RegisterScreen());

      case AppRoutes.home:
        return _buildRoute(settings, const HomeScreen());

      case AppRoutes.search:
        return _buildRoute(settings, const GiftSearchScreen());

      case AppRoutes.productResults:
        final criteria = settings.arguments;

        return _buildRoute(
          settings,
          ProductResultsScreen(
            criteria: criteria is GiftSearchCriteria ? criteria : null,
          ),
        );

      case AppRoutes.productDetail:
        final product = settings.arguments;

        return _buildRoute(
          settings,
          ProductDetailScreen(product: product is GiftProduct ? product : null),
        );

      case AppRoutes.cart:
        final items = _extractCartItems(settings.arguments);

        return _buildRoute(settings, CartScreen(initialItems: items));

      case AppRoutes.checkout:
        final items = _extractCartItems(settings.arguments);

        return _buildRoute(settings, CheckoutScreen(items: items));

      default:
        return _buildRoute(settings, const _UnknownRouteScreen());
    }
  }

  static MaterialPageRoute<dynamic> _buildRoute(
    RouteSettings settings,
    Widget screen,
  ) {
    return MaterialPageRoute<dynamic>(
      builder: (_) => screen,
      settings: settings,
    );
  }

  /// Obtiene únicamente CartItem válidos de los argumentos recibidos.
  ///
  /// Durante esta primera fase evita que un argumento incorrecto
  /// provoque un error de ejecución.
  static List<CartItem> _extractCartItems(Object? arguments) {
    if (arguments is List<CartItem>) {
      return List<CartItem>.unmodifiable(arguments);
    }

    return const [];
  }
}

class _UnknownRouteScreen extends StatelessWidget {
  const _UnknownRouteScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const Center(child: Text('Ruta no encontrada')),
    );
  }
}
