import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/addresses/screens/address_list_screen.dart';
import '../features/cart/screens/cart_screen.dart';
import '../features/cart/screens/checkout_screen.dart';
import '../features/checkout/models/checkout_success_data.dart';
import '../features/checkout/screens/checkout_success_screen.dart';
import '../features/products/screens/product_detail_screen.dart';
import '../features/payments/screens/add_payment_method_screen.dart';
import '../features/payments/screens/payment_methods_screen.dart';
import '../features/products/screens/product_results_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/search/screens/gift_search_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../shared/models/cart_item.dart';
import '../shared/models/gift_product.dart';
import '../shared/models/gift_search_criteria.dart';
import 'app_tab.dart';
import 'app_tab_notifier.dart';
import 'auth_gate.dart';
import 'main_shell.dart';

/// Nombres centralizados de las rutas de Giftify.
///
/// Se deben utilizar estas constantes en lugar de escribir
/// manualmente rutas como "/cart" o "/products".
abstract final class AppRoutes {
  static const String root = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String paymentMethods = '/payment-methods';
  static const String addPaymentMethod = '/payment-methods/new';
  static const String search = '/search';
  static const String productResults = '/products';
  static const String productDetail = '/products/detail';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String checkoutSuccess = '/checkout/success';
  static const String addresses = '/addresses';
}

/// Router central de Giftify.
///
/// Todas las pantallas utilizan esta configuración para evitar
/// que cada módulo implemente un sistema de navegación diferente.
abstract final class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.root:
        return _buildRoute(settings, const AuthGate());

      case AppRoutes.home:
        return _buildRoute(settings, const AuthGate());

      case AppRoutes.login:
        return _buildRoute(
          settings,
          const AuthGate(initialView: AuthView.login),
        );

      case AppRoutes.register:
        return _buildRoute(
          settings,
          const AuthGate(initialView: AuthView.register),
        );

      case AppRoutes.profile:
        return _buildRoute(
          settings,
          const AuthGate(authenticatedChild: ProfileScreen()),
        );

      case AppRoutes.settings:
        return _buildRoute(
          settings,
          const AuthGate(authenticatedChild: SettingsScreen()),
        );

      case AppRoutes.paymentMethods:
        return _buildRoute(
          settings,
          const AuthGate(authenticatedChild: PaymentMethodsScreen()),
        );

      case AppRoutes.addPaymentMethod:
        return _buildRoute(
          settings,
          const AuthGate(authenticatedChild: AddPaymentMethodScreen()),
        );

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

        return _buildRoute(
          settings,
          AuthGate(authenticatedChild: CartScreen(initialItems: items)),
        );

      case AppRoutes.checkout:
        return _buildRoute(
          settings,
          const AuthGate(authenticatedChild: CheckoutScreen()),
        );

      case AppRoutes.checkoutSuccess:
        final arguments = settings.arguments;

        return _buildRoute(
          settings,
          AuthGate(
            authenticatedChild: arguments is CheckoutSuccessData
                ? CheckoutSuccessScreen(data: arguments)
                : const _CheckoutSuccessFallback(),
          ),
        );

      case AppRoutes.addresses:
        return _buildRoute(
          settings,
          const AuthGate(authenticatedChild: AddressListScreen()),
        );

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

/// Evita mostrar una confirmación falsa cuando llega un deep link sin datos.
class _CheckoutSuccessFallback extends ConsumerStatefulWidget {
  const _CheckoutSuccessFallback();

  @override
  ConsumerState<_CheckoutSuccessFallback> createState() =>
      _CheckoutSuccessFallbackState();
}

class _CheckoutSuccessFallbackState
    extends ConsumerState<_CheckoutSuccessFallback> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(appTabProvider.notifier).select(AppTab.home);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const MainShell();
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
