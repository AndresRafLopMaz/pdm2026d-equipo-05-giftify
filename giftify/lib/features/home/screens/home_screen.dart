import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_router.dart';
import '../../../app/app_tab.dart';
import '../../../app/app_tab_notifier.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/enums/gift_format.dart';
import '../../../shared/enums/gift_interest.dart';
import '../../../shared/enums/gift_occasion.dart';
import '../../../shared/enums/gift_recipient.dart';
import '../../auth/providers/auth_controller.dart';
import '../../profile/widgets/user_avatar.dart';
import '../../search/models/search_prefill.dart';
import '../../search/providers/search_prefill_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final giftify = GiftifyColors.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final horizontalPadding = width >= 600 ? 24.0 : 16.0;
    final user = ref.watch(authControllerProvider).value;
    final greeting = _greetingFor(user?.name);

    final categories = <_CategoryIdea>[
      _CategoryIdea(
        id: 'birthday',
        label: 'Cumpleaños',
        icon: Icons.cake_rounded,
        foreground: giftify.warmStrong,
        background: giftify.warmSoft,
        prefill: const SearchPrefill(occasion: GiftOccasion.birthday),
      ),
      _CategoryIdea(
        id: 'partner',
        label: 'Pareja',
        icon: Icons.favorite_rounded,
        foreground: giftify.blushStrong,
        background: giftify.blushSoft,
        prefill: const SearchPrefill(recipientType: GiftRecipient.partner),
      ),
      _CategoryIdea(
        id: 'family',
        label: 'Familia',
        icon: Icons.family_restroom_rounded,
        foreground: giftify.secondaryStrong,
        background: giftify.secondarySoft,
        prefill: const SearchPrefill(recipientType: GiftRecipient.family),
      ),
      _CategoryIdea(
        id: 'friends',
        label: 'Amigos',
        icon: Icons.groups_rounded,
        foreground: colors.primary,
        background: colors.primaryContainer,
        prefill: const SearchPrefill(recipientType: GiftRecipient.friend),
      ),
      _CategoryIdea(
        id: 'technology',
        label: 'Tecnología',
        icon: Icons.devices_rounded,
        foreground: colors.primary,
        background: colors.primaryContainer,
        prefill: const SearchPrefill(interests: {GiftInterest.technology}),
      ),
      _CategoryIdea(
        id: 'experiences',
        label: 'Experiencias',
        icon: Icons.local_activity_rounded,
        foreground: giftify.warmStrong,
        background: giftify.warmSoft,
        prefill: const SearchPrefill(giftFormat: GiftFormat.experience),
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          key: const PageStorageKey('home-scroll'),
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            20,
            horizontalPadding,
            32,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _BrandHeader(
                    name: user?.name ?? '',
                    onProfile: () {
                      Navigator.pushNamed(context, AppRoutes.profile);
                    },
                  ),
                  const SizedBox(height: 28),
                  Text(
                    greeting,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '¿A quién quieres sorprender?',
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Encuentra ideas de regalo según la ocasión, presupuesto y persona.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _SearchHero(
                    onSearch: () {
                      ref.read(appTabProvider.notifier).select(AppTab.search);
                    },
                  ),
                  const SizedBox(height: 32),
                  const _SectionTitle(title: 'Explora'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final category in categories)
                        _CategoryPill(
                          category: category,
                          onTap: () {
                            ref
                                .read(searchPrefillProvider.notifier)
                                .set(category.prefill);
                            ref
                                .read(appTabProvider.notifier)
                                .select(AppTab.search);
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const _SectionTitle(title: 'Accesos rápidos'),
                  const SizedBox(height: 12),
                  _QuickAccessGrid(
                    onCatalog: () {
                      ref.read(appTabProvider.notifier).select(AppTab.catalog);
                    },
                    onCart: () {
                      ref.read(appTabProvider.notifier).select(AppTab.cart);
                    },
                    onAddresses: () {
                      Navigator.pushNamed(context, AppRoutes.addresses);
                    },
                  ),
                  const SizedBox(height: 32),
                  _EditorialBanner(
                    onCatalog: () {
                      ref.read(appTabProvider.notifier).select(AppTab.catalog);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _greetingFor(String? name) {
    final normalized = name?.trim() ?? '';
    if (normalized.isEmpty) {
      return 'Hola';
    }

    final firstName = normalized.split(RegExp(r'\s+')).first;
    return 'Hola, $firstName';
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader({required this.name, required this.onProfile});

  final String name;
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(
            Icons.card_giftcard_rounded,
            color: colors.primary,
            size: 22,
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              'Giftify',
              style: theme.textTheme.titleLarge?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const Spacer(),
        IconButton(
          key: const ValueKey('profile-button'),
          onPressed: onProfile,
          tooltip: 'Ver perfil',
          icon: UserAvatar(name: name, radius: 18),
        ),
      ],
    );
  }
}

class _SearchHero extends StatelessWidget {
  const _SearchHero({required this.onSearch});

  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final giftify = GiftifyColors.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        children: [
          Positioned.fill(child: ColoredBox(color: colors.primaryContainer)),
          Positioned(
            right: -34,
            top: -42,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: giftify.blush.withValues(alpha: 0.32),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.redeem_rounded,
                        color: colors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Un regalo para cada historia',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Cuéntanos qué necesitas y descubre opciones para esa persona especial.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        key: const ValueKey('home-search-action'),
                        onPressed: onSearch,
                        child: const Text(
                          'Buscar el regalo ideal',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}

class _CategoryIdea {
  const _CategoryIdea({
    required this.id,
    required this.label,
    required this.icon,
    required this.foreground,
    required this.background,
    required this.prefill,
  });

  final String id;
  final String label;
  final IconData icon;
  final Color foreground;
  final Color background;
  final SearchPrefill prefill;
}

class _CategoryPill extends StatelessWidget {
  const _CategoryPill({required this.category, required this.onTap});

  final _CategoryIdea category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Buscar por ${category.label}',
      child: ExcludeSemantics(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            key: ValueKey('home-category-${category.id}'),
            borderRadius: BorderRadius.circular(999),
            onTap: onTap,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: 48,
                maxWidth: MediaQuery.sizeOf(context).width - 32,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: category.background,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(category.icon, size: 18, color: category.foreground),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          category.label,
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: category.foreground,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickAccessGrid extends StatelessWidget {
  const _QuickAccessGrid({
    required this.onCatalog,
    required this.onCart,
    required this.onAddresses,
  });

  final VoidCallback onCatalog;
  final VoidCallback onCart;
  final VoidCallback onAddresses;

  @override
  Widget build(BuildContext context) {
    final giftify = GiftifyColors.of(context);
    final colors = Theme.of(context).colorScheme;

    final tiles = <Widget>[
      _QuickAccessTile(
        key: const ValueKey('home-catalog-action'),
        icon: Icons.storefront_rounded,
        iconForeground: giftify.secondaryStrong,
        iconBackground: giftify.secondarySoft,
        title: 'Catálogo',
        description: 'Explora todos los regalos',
        onTap: onCatalog,
      ),
      _QuickAccessTile(
        key: const ValueKey('home-cart-action'),
        icon: Icons.shopping_cart_rounded,
        iconForeground: giftify.blushStrong,
        iconBackground: giftify.blushSoft,
        title: 'Mi carrito',
        description: 'Revisa lo que guardaste',
        onTap: onCart,
      ),
      _QuickAccessTile(
        key: const ValueKey('home-addresses-action'),
        icon: Icons.location_on_rounded,
        iconForeground: colors.primary,
        iconBackground: colors.primaryContainer,
        title: 'Direcciones',
        description: 'Administra tus entregas',
        onTap: onAddresses,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 360) {
          return Column(
            children: [
              tiles[0],
              const SizedBox(height: 12),
              tiles[1],
              const SizedBox(height: 12),
              tiles[2],
            ],
          );
        }

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: tiles[0]),
              const SizedBox(width: 12),
              Expanded(child: tiles[1]),
              const SizedBox(width: 12),
              Expanded(child: tiles[2]),
            ],
          ),
        );
      },
    );
  }
}

class _QuickAccessTile extends StatelessWidget {
  const _QuickAccessTile({
    super.key,
    required this.icon,
    required this.iconForeground,
    required this.iconBackground,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final Color iconForeground;
  final Color iconBackground;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Semantics(
      button: true,
      label: '$title. $description',
      child: ExcludeSemantics(
        child: Material(
          color: colors.surface,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: colors.outlineVariant),
          ),
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: iconBackground,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, color: iconForeground, size: 21),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: colors.onSurfaceVariant,
                        size: 18,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EditorialBanner extends StatelessWidget {
  const _EditorialBanner({required this.onCatalog});

  final VoidCallback onCatalog;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final giftify = GiftifyColors.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: giftify.warmSoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                color: giftify.warmStrong,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Ideas para regalar',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colors.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '¿No sabes por dónde empezar? Explora nuestro catálogo y descubre opciones para diferentes ocasiones.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              key: const ValueKey('home-editorial-catalog-action'),
              onPressed: onCatalog,
              style: TextButton.styleFrom(foregroundColor: giftify.warmStrong),
              child: const Text('Ver catálogo', textAlign: TextAlign.center),
            ),
          ),
        ],
      ),
    );
  }
}
