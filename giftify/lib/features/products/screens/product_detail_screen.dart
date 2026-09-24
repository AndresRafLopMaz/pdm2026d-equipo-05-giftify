import 'package:flutter/material.dart';

import '../../../app/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/enums/gift_availability.dart';
import '../../../shared/models/cart_item.dart';
import '../../../shared/models/gift_product.dart';
import '../widgets/availability_badge.dart';

/// Pantalla 5 — Detalle del producto.
///
/// Responsable principal: Andrés.
///
/// Recibe el producto seleccionado desde la pantalla de resultados a través
/// del contrato central de rutas. Si [product] es `null` muestra un estado
/// seguro en lugar de fallar.
class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key, this.product});

  final GiftProduct? product;

  @override
  Widget build(BuildContext context) {
    final product = this.product;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del producto'),
        backgroundColor: fondoPrincipal,
      ),
      body: SafeArea(
        child: product == null
            ? const _NullProductState()
            : _DetailContent(product: product),
      ),
    );
  }
}

/// Contenido completo cuando el producto existe.
class _DetailContent extends StatelessWidget {
  const _DetailContent({required this.product});

  final GiftProduct product;

  @override
  Widget build(BuildContext context) {
    final days = product.estimatedDeliveryDays;
    final canAddToCart = product.isAvailable;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProductImage(imageAsset: product.imageAsset),
          const SizedBox(height: 20),

          Text(
            product.name,
            style: const TextStyle(
              color: textoPrincipal,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 14),

          // Precio, disponibilidad y entrega con jerarquía visual clara.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE4E8E6)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Q ${product.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: verdeOscuro,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    AvailabilityBadge(availability: product.availability),
                    if (days != null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.local_shipping_outlined,
                            size: 16,
                            color: textoSecundario,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Entrega estimada: $days ${days == 1 ? 'día' : 'días'}',
                            style: const TextStyle(
                              color: textoSecundario,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoTag(label: 'Categoría', value: product.category),
              _InfoTag(label: 'Tamaño', value: product.size),
            ],
          ),
          const SizedBox(height: 22),

          const Text(
            'Descripción',
            style: TextStyle(
              color: textoPrincipal,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            product.description,
            style: const TextStyle(
              color: textoSecundario,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 22),

          _SellerSection(product: product),
          const SizedBox(height: 22),

          if (product.availability == GiftAvailability.unknown) ...[
            const _UnknownAvailabilityNotice(),
            const SizedBox(height: 12),
          ],

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: canAddToCart ? () => _addToCart(context) : null,
              style: FilledButton.styleFrom(
                backgroundColor: verdePrincipal,
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFFD9DEDC),
                disabledForegroundColor: textoSecundario,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.add_shopping_cart_rounded),
              label: const Text(
                'Agregar al carrito',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          if (!canAddToCart) ...[
            const SizedBox(height: 10),
            Text(
              _unavailableMessage(product.availability),
              textAlign: TextAlign.center,
              style: const TextStyle(color: textoSecundario, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  /// Crea el [CartItem] y navega al carrito usando el contrato existente.
  void _addToCart(BuildContext context) {
    final item = CartItem(product: product);

    Navigator.pushNamed(context, AppRoutes.cart, arguments: [item]);
  }

  String _unavailableMessage(GiftAvailability availability) {
    switch (availability) {
      case GiftAvailability.outOfStock:
        return 'Este producto está agotado por el momento.';
      case GiftAvailability.unknown:
        return 'Confirma la disponibilidad con el vendedor antes de continuar.';
      case GiftAvailability.inStock:
      case GiftAvailability.lowStock:
        return '';
    }
  }
}

/// Imagen del producto con placeholder seguro cuando no existe asset.
class _ProductImage extends StatelessWidget {
  const _ProductImage({this.imageAsset});

  final String? imageAsset;

  @override
  Widget build(BuildContext context) {
    final asset = imageAsset;
    final placeholder = Container(
      color: verdeClaro,
      alignment: Alignment.center,
      child: const Icon(
        Icons.card_giftcard_rounded,
        color: verdePrincipal,
        size: 72,
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: SizedBox(
        width: double.infinity,
        height: 220,
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

/// Pequeña etiqueta informativa (categoría, tamaño).
class _InfoTag extends StatelessWidget {
  const _InfoTag({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: verdeClaro,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          color: verdeOscuro,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Sección "Detalles del vendedor" limitada a los datos existentes.
class _SellerSection extends StatelessWidget {
  const _SellerSection({required this.product});

  final GiftProduct product;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE4E8E6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.storefront_rounded,
                color: verdePrincipal,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Detalles del vendedor',
                style: TextStyle(
                  color: textoPrincipal,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: verdeClaro,
                child: Icon(Icons.store_rounded, color: verdePrincipal),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  product.sellerName,
                  style: const TextStyle(
                    color: textoPrincipal,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.star_rounded,
                color: amarilloPrincipal,
                size: 20,
              ),
              const SizedBox(width: 6),
              Text(
                '${product.sellerRating.toStringAsFixed(1)} / 5',
                style: const TextStyle(
                  color: textoPrincipal,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Advertencia conservadora cuando la disponibilidad es desconocida.
class _UnknownAvailabilityNotice extends StatelessWidget {
  const _UnknownAvailabilityNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5D8),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: Color(0xFFB0790A), size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'La disponibilidad de este producto aún no está confirmada. '
              'No podemos asegurar que esté disponible.',
              style: TextStyle(
                color: Color(0xFFB0790A),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Estado seguro cuando no se recibió un producto válido.
class _NullProductState extends StatelessWidget {
  const _NullProductState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: verdeClaro,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: verdePrincipal,
                size: 40,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No se pudo cargar la información del producto.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textoPrincipal,
                fontSize: 16,
                fontWeight: FontWeight.bold,
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
