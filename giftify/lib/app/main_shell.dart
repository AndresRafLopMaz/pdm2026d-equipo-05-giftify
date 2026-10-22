import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/home/screens/home_screen.dart';
import '../features/products/screens/product_results_screen.dart';
import '../features/search/screens/gift_search_screen.dart';
import 'app_tab.dart';
import 'app_tab_notifier.dart';
import 'coming_soon_screen.dart';

/// Contenedor principal de Giftify con navegación por pestañas.
///
/// Mantiene las pantallas montadas mediante [IndexedStack] para conservar su
/// estado y el scroll. Las rutas de detalle, carrito y checkout siguen
/// gestionándose con [AppRouter].
class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  static const List<Widget> _screens = <Widget>[
    HomeScreen(),
    GiftSearchScreen(),
    ProductResultsScreen(),
    ComingSoonScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(appTabProvider);

    return Scaffold(
      body: IndexedStack(
        key: const ValueKey('main-shell-stack'),
        index: selectedTab.index,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedTab.index,
        onDestinationSelected: (index) {
          ref.read(appTabProvider.notifier).select(AppTab.values[index]);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search_rounded),
            label: 'Buscar',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view_rounded),
            label: 'Catálogo',
          ),
          NavigationDestination(
            icon: Icon(Icons.hourglass_empty_outlined),
            selectedIcon: Icon(Icons.hourglass_empty_rounded),
            label: 'Próximamente',
          ),
        ],
      ),
    );
  }
}
