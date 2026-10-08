import 'package:flutter/material.dart';

import '../../../app/app_router.dart';
import '../../../core/theme/app_theme.dart';
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
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _buildImagePlaceholder(),
      );
    }

    return _buildImagePlaceholder();
  }

  Widget _buildImagePlaceholder() {
    return Container(
      key: const ValueKey('product-image-placeholder'),
      width: 80,
      height: 80,
      color: rosaClaro,
      alignment: Alignment.center,
      child: Icon(Icons.card_giftcard_rounded, color: rosaPrincipal, size: 32),
    );
  }

  Widget _buildCartItem(BuildContext context, int index) {
    final item = _items[index];
    final product = item.product;
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: colors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.7)),
      ),
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
                            visualDensity: VisualDensity.compact,
                            color: rosaPrincipal,
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
                    IconButton(
                      key: ValueKey('decrease-${product.id}'),
                      tooltip: 'Disminuir cantidad',
                      onPressed: item.quantity > 1
                          ? () => _decreaseQuantity(index)
                          : null,
                      constraints: const BoxConstraints.tightFor(
                        width: 36,
                        height: 36,
                      ),
                      padding: EdgeInsets.zero,
                      style: IconButton.styleFrom(
                        backgroundColor: rosaClaro,
                        foregroundColor: rosaPrincipal,
                        disabledBackgroundColor: colors.surfaceContainerHighest,
                      ),
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
                    IconButton(
                      key: ValueKey('increase-${product.id}'),
                      tooltip: 'Aumentar cantidad',
                      onPressed: () => _increaseQuantity(index),
                      constraints: const BoxConstraints.tightFor(
                        width: 36,
                        height: 36,
                      ),
                      padding: EdgeInsets.zero,
                      style: IconButton.styleFrom(
                        backgroundColor: rosaClaro,
                        foregroundColor: rosaPrincipal,
                      ),
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
            const Icon(
              Icons.shopping_cart_outlined,
              size: 72,
              color: rosaPrincipal,
            ),
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
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: colors.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
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
                        color: rosaPrincipal,
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
                  style: FilledButton.styleFrom(
                    backgroundColor: rosaPrincipal,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: colors.surfaceContainerHighest,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
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
      appBar: AppBar(
        title: const Text('Carrito'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
            height: 1,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
      body: _items.isEmpty
          ? _buildEmptyCart(context)
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: _items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: _buildCartItem,
            ),
      bottomNavigationBar: _buildCheckoutBar(context),
    );
  }
}
