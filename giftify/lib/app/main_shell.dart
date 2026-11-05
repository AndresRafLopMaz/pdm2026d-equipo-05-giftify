import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/cart/screens/cart_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/products/screens/product_results_screen.dart';
import '../features/search/screens/gift_search_screen.dart';
import 'app_tab.dart';
import 'app_tab_notifier.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  static const List<Widget> _screens = <Widget>[
    HomeScreen(),
    GiftSearchScreen(),
    ProductResultsScreen(),
    CartScreen(),
  ];

  final Set<AppTab> _visitedTabs = {AppTab.home};

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final selectedTab = ref.watch(appTabProvider);
    ref.listen(appTabProvider, (previous, next) {
      if (!_visitedTabs.contains(next)) {
        setState(() {
          _visitedTabs.add(next);
        });
      }
    });

    return Scaffold(
      body: IndexedStack(
        key: const ValueKey('main-shell-stack'),
        index: selectedTab.index,
        children: [
          for (var index = 0; index < _screens.length; index++)
            TickerMode(
              enabled: selectedTab.index == index,
              child: _visitedTabs.contains(AppTab.values[index])
                  ? _screens[index]
                  : const SizedBox.shrink(),
            ),
        ],
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(top: BorderSide(color: colors.outlineVariant)),
        ),
        child: NavigationBar(
          selectedIndex: selectedTab.index,
          onDestinationSelected: (index) {
            final tab = AppTab.values[index];
            setState(() {
              _visitedTabs.add(tab);
            });
            ref.read(appTabProvider.notifier).select(tab);
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
              icon: Icon(Icons.shopping_cart_outlined),
              selectedIcon: Icon(Icons.shopping_cart_rounded),
              label: 'Carrito',
            ),
          ],
        ),
      ),
    );
  }
}
