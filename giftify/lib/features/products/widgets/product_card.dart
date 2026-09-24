import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/models/gift_product.dart';
import 'availability_badge.dart';

/// Tarjeta resumida de un producto dentro de la lista de resultados.
///
/// Es un widget desacoplado del router: la navegación se delega al
/// callback [onTap] para mantener la tarjeta reutilizable.
class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product, this.onTap});

  final GiftProduct product;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFE4E8E6)),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProductThumbnail(imageAsset: product.imageAsset),
              const SizedBox(width: 14),
              Expanded(child: _ProductInfo(product: product)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Miniatura del producto. Muestra un placeholder cuando no existe imagen.
class _ProductThumbnail extends StatelessWidget {
  const _ProductThumbnail({this.imageAsset});

  final String? imageAsset;

  @override
  Widget build(BuildContext context) {
    final asset = imageAsset;

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: 84,
        height: 84,
        child: asset == null
            ? const _ThumbnailPlaceholder()
            : Image.asset(
                asset,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const _ThumbnailPlaceholder(),
              ),
      ),
    );
  }
}

class _ThumbnailPlaceholder extends StatelessWidget {
  const _ThumbnailPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: verdeClaro,
      alignment: Alignment.center,
      child: const Icon(
        Icons.card_giftcard_rounded,
        color: verdePrincipal,
        size: 36,
      ),
    );
  }
}

/// Información textual resumida de la tarjeta.
class _ProductInfo extends StatelessWidget {
  const _ProductInfo({required this.product});

  final GiftProduct product;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: textoPrincipal,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          product.category,
          style: const TextStyle(color: textoSecundario, fontSize: 12),
        ),
        const SizedBox(height: 8),
        Text(
          'Q ${product.price.toStringAsFixed(2)}',
          style: const TextStyle(
            color: verdeOscuro,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        AvailabilityBadge(availability: product.availability),
        const SizedBox(height: 8),
        _SellerLine(
          sellerName: product.sellerName,
          sellerRating: product.sellerRating,
        ),
        if (product.estimatedDeliveryDays != null) ...[
          const SizedBox(height: 4),
          _DeliveryLine(days: product.estimatedDeliveryDays!),
        ],
      ],
    );
  }
}

class _SellerLine extends StatelessWidget {
  const _SellerLine({required this.sellerName, required this.sellerRating});

  final String sellerName;
  final double sellerRating;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.storefront_outlined, size: 14, color: textoSecundario),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            sellerName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: textoSecundario, fontSize: 12),
          ),
        ),
        const SizedBox(width: 8),
        const Icon(Icons.star_rounded, size: 14, color: amarilloPrincipal),
        const SizedBox(width: 2),
        Text(
          sellerRating.toStringAsFixed(1),
          style: const TextStyle(
            color: textoPrincipal,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _DeliveryLine extends StatelessWidget {
  const _DeliveryLine({required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.local_shipping_outlined,
          size: 14,
          color: textoSecundario,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            'Entrega estimada: $days ${days == 1 ? 'día' : 'días'}',
            style: const TextStyle(color: textoSecundario, fontSize: 12),
          ),
        ),
      ],
    );
  }
}
