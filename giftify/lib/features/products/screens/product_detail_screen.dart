import 'package:flutter/material.dart';

import '../../../app/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/enums/gift_availability.dart';
import '../../../shared/models/cart_item.dart';
import '../../../shared/models/gift_product.dart';
import '../widgets/availability_badge.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key, this.product});

  final GiftProduct? product;

  @override
  Widget build(BuildContext context) {
    final product = this.product;

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle')),
      body: SafeArea(
        bottom: false,
        child: product == null
            ? const _NullProductState()
            : _DetailContent(product: product),
      ),
      bottomNavigationBar: product == null
          ? null
          : _AddToCartBar(product: product),
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({required this.product});

  final GiftProduct product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final horizontalPadding = MediaQuery.sizeOf(context).width >= 600
        ? 24.0
        : 16.0;
    final days = product.estimatedDeliveryDays;
    final meta = <String>[
      product.category,
      product.size,
      if (days != null) 'Entrega estimada: $days ${days == 1 ? 'día' : 'días'}',
    ].join(' · ');

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            16,
            horizontalPadding,
            24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ProductImage(imageAsset: product.imageAsset),
              const SizedBox(height: 20),
              Text(
                product.name,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'Q ${product.price.toStringAsFixed(2)}',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  AvailabilityBadge(availability: product.availability),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                meta,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Descripción',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                product.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 20),
              _SellerSection(product: product),
              if (product.availability == GiftAvailability.unknown) ...[
                const SizedBox(height: 20),
                const _UnknownAvailabilityNotice(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AddToCartBar extends StatelessWidget {
  const _AddToCartBar({required this.product});

  final GiftProduct product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final canAddToCart = product.isAvailable;
    final horizontalPadding = MediaQuery.sizeOf(context).width >= 600
        ? 24.0
        : 16.0;

    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(top: BorderSide(color: colors.outlineVariant)),
        ),
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          12,
          horizontalPadding,
          12,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (product.availability == GiftAvailability.outOfStock) ...[
                  Text(
                    'Este producto está agotado por el momento.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    key: const ValueKey('detail-add-to-cart'),
                    onPressed: canAddToCart ? () => _addToCart(context) : null,
                    icon: const Icon(Icons.add_shopping_cart_rounded),
                    label: const Text('Agregar al carrito'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _addToCart(BuildContext context) {
    final item = CartItem(product: product);

    Navigator.pushNamed(context, AppRoutes.cart, arguments: [item]);
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({this.imageAsset});

  final String? imageAsset;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final asset = imageAsset;
    final placeholder = ColoredBox(
      color: colors.primaryContainer,
      child: Icon(Icons.card_giftcard_rounded, color: colors.primary, size: 64),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: double.infinity,
        height: 240,
        child: asset == null
            ? placeholder
            : Image.asset(
                asset,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => placeholder,
              ),
      ),
    );
  }
}

class _SellerSection extends StatelessWidget {
  const _SellerSection({required this.product});

  final GiftProduct product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vendedor',
          style: theme.textTheme.titleMedium?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Icon(
              Icons.storefront_outlined,
              color: colors.onSurfaceVariant,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                product.sellerName,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.star_rounded, color: colors.tertiary, size: 18),
            const SizedBox(width: 4),
            Text(
              '${product.sellerRating.toStringAsFixed(1)} / 5',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _UnknownAvailabilityNotice extends StatelessWidget {
  const _UnknownAvailabilityNotice();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: giftifyWarningBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: giftifyWarning,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'La disponibilidad de este producto aún no está confirmada. '
              'No podemos asegurar que esté disponible.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: giftifyWarning,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NullProductState extends StatelessWidget {
  const _NullProductState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, color: colors.error, size: 48),
            const SizedBox(height: 16),
            Text(
              'No se pudo cargar la información del producto.',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Volver'),
            ),
          ],
        ),
      ),
    );
  }
}
