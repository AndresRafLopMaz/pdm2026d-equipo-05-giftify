import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_router.dart';
import '../../../app/app_tab.dart';
import '../../../app/app_tab_notifier.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final width = MediaQuery.sizeOf(context).width;
    final horizontalPadding = width >= 600 ? 24.0 : 16.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Giftify')),
      body: SafeArea(
        child: SingleChildScrollView(
          key: const PageStorageKey('home-scroll'),
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            24,
            horizontalPadding,
            32,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Encuentra el regalo ideal',
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Elige una ocasión, un presupuesto y descubre opciones para regalar sin complicarte.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    key: const ValueKey('home-search-action'),
                    onPressed: () {
                      ref.read(appTabProvider.notifier).select(AppTab.search);
                    },
                    icon: const Icon(Icons.search_rounded),
                    label: const Text('Buscar un regalo'),
                  ),
                  const SizedBox(height: 32),
                  const Divider(),
                  _HomeAction(
                    key: const ValueKey('home-catalog-action'),
                    icon: Icons.storefront_outlined,
                    title: 'Catálogo',
                    subtitle: 'Explora todos los regalos disponibles',
                    onTap: () {
                      ref.read(appTabProvider.notifier).select(AppTab.catalog);
                    },
                  ),
                  const Divider(),
                  _HomeAction(
                    key: const ValueKey('home-cart-action'),
                    icon: Icons.shopping_cart_outlined,
                    title: 'Carrito',
                    subtitle: 'Revisa los productos que guardaste',
                    onTap: () {
                      ref.read(appTabProvider.notifier).select(AppTab.cart);
                    },
                  ),
                  const Divider(),
                  _HomeAction(
                    key: const ValueKey('home-addresses-action'),
                    icon: Icons.location_on_outlined,
                    title: 'Mis direcciones',
                    subtitle: 'Administra tus lugares de entrega',
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.addresses);
                    },
                  ),
                  const Divider(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeAction extends StatelessWidget {
  const _HomeAction({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: colors.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: colors.primary),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          color: colors.onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colors.onSurfaceVariant,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: colors.onSurfaceVariant,
      ),
    );
  }
}
