import 'package:flutter/material.dart';

import '../../../app/app_router.dart';
import '../../../shared/models/cart_item.dart';

/// Pantalla 6 — Carrito de compras.
///
/// Responsable principal: Catherine.
///
/// La lista inicial permite recibir productos seleccionados desde
/// otras pantallas sin definir todavía un gestor global de estado.
class CartScreen extends StatefulWidget {
  const CartScreen({super.key, this.initialItems = const []});

  final List<CartItem> initialItems;

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late final List<CartItem> _items;

  double get _total => _items.fold(0, (total, item) => total + item.subtotal);

  @override
  void initState() {
    super.initState();
    _items = List<CartItem>.of(widget.initialItems);
  }

  String _formatPrice(double price) => 'Q ${price.toStringAsFixed(2)}';

  void _increaseQuantity(int index) {
    setState(() {
      final item = _items[index];
      _items[index] = item.copyWith(quantity: item.quantity + 1);
    });
  }

  void _decreaseQuantity(int index) {
    final item = _items[index];
    if (item.quantity == 1) {
      return;
    }

    setState(() {
      _items[index] = item.copyWith(quantity: item.quantity - 1);
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  void _continueToCheckout() {
    Navigator.pushNamed(
      context,
      AppRoutes.checkout,
      arguments: List<CartItem>.of(_items),
    );
  }

  bool _hasValidImageUrl(String? value) {
    if (value == null) {
      return false;
    }

    final uri = Uri.tryParse(value);
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  Widget _buildProductImage(CartItem item) {
    final imageUrl = item.product.imageAsset;

    if (_hasValidImageUrl(imageUrl)) {
      return Image.network(
        imageUrl!,
        width: 88,
        height: 88,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _buildImagePlaceholder(),
      );
    }

    return _buildImagePlaceholder();
  }

  Widget _buildImagePlaceholder() {
    final colors = Theme.of(context).colorScheme;

    return Container(
      key: const ValueKey('product-image-placeholder'),
      width: 88,
      height: 88,
      color: colors.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(
        Icons.card_giftcard_rounded,
        color: colors.onSurfaceVariant,
        size: 36,
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, int index) {
    final item = _items[index];
    final product = item.product;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildProductImage(item),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          IconButton(
                            key: ValueKey('remove-${product.id}'),
                            tooltip: 'Eliminar ${product.name}',
                            onPressed: () => _removeItem(index),
                            icon: const Icon(Icons.delete_outline_rounded),
                          ),
                        ],
                      ),
                      Text(
                        'Precio unitario: ${_formatPrice(product.price)}',
                        style: textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton.filledTonal(
                      key: ValueKey('decrease-${product.id}'),
                      tooltip: 'Disminuir cantidad',
                      onPressed: item.quantity > 1
                          ? () => _decreaseQuantity(index)
                          : null,
                      icon: const Icon(Icons.remove_rounded),
                    ),
                    SizedBox(
                      width: 36,
                      child: Text(
                        '${item.quantity}',
                        key: ValueKey('quantity-${product.id}'),
                        textAlign: TextAlign.center,
                        style: textTheme.titleMedium,
                      ),
                    ),
                    IconButton.filledTonal(
                      key: ValueKey('increase-${product.id}'),
                      tooltip: 'Aumentar cantidad',
                      onPressed: () => _increaseQuantity(index),
                      icon: const Icon(Icons.add_rounded),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Subtotal', style: textTheme.labelMedium),
                    Text(
                      _formatPrice(item.subtotal),
                      key: ValueKey('subtotal-${product.id}'),
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 72, color: colors.primary),
            const SizedBox(height: 20),
            Text(
              'Tu carrito está vacío',
              textAlign: TextAlign.center,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Agrega un regalo para continuar con tu compra.',
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutBar(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      top: false,
      child: Material(
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_items.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total', style: textTheme.titleMedium),
                    Text(
                      _formatPrice(_total),
                      key: const ValueKey('cart-total'),
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  key: const ValueKey('checkout-button'),
                  onPressed: _items.isEmpty ? null : _continueToCheckout,
                  child: const Text('Continuar al pago'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Carrito')),
      body: _items.isEmpty
          ? _buildEmptyCart(context)
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: _buildCartItem,
            ),
      bottomNavigationBar: _buildCheckoutBar(context),
    );
  }
}
