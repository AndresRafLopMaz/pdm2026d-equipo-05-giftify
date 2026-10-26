import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/cart_item.dart';
import '../data/cart_repository.dart';
import '../providers/cart_filter_provider.dart';
import '../providers/cart_items_provider.dart';

/// Pantalla 6 — Carrito de compras.
///
/// Responsable principal: Catherine.
class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key, this.initialItems = const []});

  final List<CartItem> initialItems;

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final Map<String, RemovedCartItem> _pendingDeletions = {};
  final Set<String> _updatingIds = {};
  final Set<String> _deletingIds = {};
  late bool _isSeeding;
  bool _seedFailed = false;

  bool get _hasPendingOperation =>
      _updatingIds.isNotEmpty ||
      _deletingIds.isNotEmpty ||
      _pendingDeletions.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _isSeeding = widget.initialItems.isNotEmpty;
    if (_isSeeding) {
      _seedInitialItems();
    }
  }

  Future<void> _seedInitialItems() async {
    try {
      await ref
          .read(cartItemsProvider.notifier)
          .addIncoming(widget.initialItems);
      if (mounted) {
        setState(() {
          _isSeeding = false;
          _seedFailed = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isSeeding = false;
          _seedFailed = true;
        });
      }
    }
  }

  void _retry() {
    if (_seedFailed) {
      setState(() {
        _isSeeding = true;
        _seedFailed = false;
      });
      _seedInitialItems();
      return;
    }

    ref.invalidate(cartItemsProvider);
  }

  String _formatPrice(double price) => 'Q ${price.toStringAsFixed(2)}';

  Future<void> _changeQuantity(CartItem item, int quantity) async {
    final productId = item.product.id;
    if (quantity < 1 || _updatingIds.contains(productId)) {
      return;
    }

    setState(() => _updatingIds.add(productId));
    try {
      await ref
          .read(cartItemsProvider.notifier)
          .changeQuantity(productId, quantity);
    } catch (_) {
      if (mounted) {
        _showMessage('No se pudo actualizar la cantidad. Inténtalo de nuevo.');
      }
    } finally {
      if (mounted) {
        setState(() => _updatingIds.remove(productId));
      }
    }
  }

  Future<RemovedCartItem?> _persistRemoval(CartItem item) async {
    final productId = item.product.id;
    if (_deletingIds.contains(productId)) {
      return null;
    }

    setState(() => _deletingIds.add(productId));
    try {
      return await ref
          .read(cartItemsProvider.notifier)
          .deleteFromRepository(productId);
    } catch (_) {
      if (mounted) {
        _showMessage('No se pudo eliminar el producto. Inténtalo de nuevo.');
      }
      return null;
    } finally {
      if (mounted) {
        setState(() => _deletingIds.remove(productId));
      }
    }
  }

  Future<bool> _confirmDismiss(CartItem item) async {
    final removal = await _persistRemoval(item);
    if (removal == null) {
      return false;
    }

    if (mounted) {
      setState(() => _pendingDeletions[item.product.id] = removal);
    }
    return true;
  }

  void _onDismissed(CartItem item) {
    final removal = _pendingDeletions.remove(item.product.id);
    if (removal == null) {
      return;
    }

    ref.read(cartItemsProvider.notifier).removeLocal(removal);
    _showDeletedMessage(removal);
  }

  Future<void> _removeWithButton(CartItem item) async {
    final removal = await _persistRemoval(item);
    if (removal == null || !mounted) {
      return;
    }

    ref.read(cartItemsProvider.notifier).removeLocal(removal);
    _showDeletedMessage(removal);
  }

  void _showDeletedMessage(RemovedCartItem removal) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Producto eliminado.'),
        action: SnackBarAction(
          label: 'Deshacer',
          onPressed: () => _restore(removal),
        ),
      ),
    );
  }

  Future<void> _restore(RemovedCartItem removal) async {
    try {
      await ref.read(cartItemsProvider.notifier).restore(removal);
    } catch (_) {
      if (mounted) {
        _showMessage('No se pudo deshacer la eliminación. Inténtalo de nuevo.');
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  void _continueToCheckout(CartSnapshot snapshot) {
    Navigator.pushNamed(
      context,
      AppRoutes.checkout,
      arguments: List<CartItem>.of(snapshot.allItems),
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

  Widget _buildCartItem(BuildContext context, CartItem item) {
    final product = item.product;
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isUpdating = _updatingIds.contains(product.id);
    final isDeleting = _deletingIds.contains(product.id);

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
                            onPressed: isDeleting
                                ? null
                                : () => _removeWithButton(item),
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
                      onPressed: item.quantity > 1 && !isUpdating
                          ? () => _changeQuantity(item, item.quantity - 1)
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
                      onPressed: isUpdating
                          ? null
                          : () => _changeQuantity(item, item.quantity + 1),
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

  Widget _buildFilters(CartSnapshot snapshot) {
    final selectedCategory = snapshot.filter.category;
    final categories = snapshot.categories.toList()..sort();

    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        children: [
          FilterChip(
            key: const ValueKey('cart-filter-all'),
            label: const Text('Todos'),
            selected: selectedCategory == null,
            onSelected: _hasPendingOperation
                ? null
                : (_) {
                    ref.read(cartFilterProvider.notifier).clear();
                  },
          ),
          for (final category in categories) ...[
            const SizedBox(width: 8),
            FilterChip(
              key: ValueKey('cart-filter-category-$category'),
              label: Text(category),
              selected: selectedCategory == category,
              onSelected: _hasPendingOperation
                  ? null
                  : (_) {
                      ref
                          .read(cartFilterProvider.notifier)
                          .setCategory(category);
                    },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildItems(CartSnapshot snapshot) {
    return ListView(
      key: const PageStorageKey('cart-list'),
      padding: const EdgeInsets.only(bottom: 12),
      children: [
        _buildFilters(snapshot),
        const SizedBox(height: 6),
        for (final item in snapshot.visibleItems)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: Dismissible(
              key: ValueKey(item.product.id),
              direction: DismissDirection.endToStart,
              background: const _DeleteBackground(),
              confirmDismiss: (_) => _confirmDismiss(item),
              onDismissed: (_) => _onDismissed(item),
              child: _buildCartItem(context, item),
            ),
          ),
      ],
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

  Widget _buildFilteredEmpty(CartSnapshot snapshot) {
    return Column(
      children: [
        _buildFilters(snapshot),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.filter_alt_off_rounded,
                    size: 64,
                    color: rosaPrincipal,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No hay productos en esta categoría.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    key: const ValueKey('clear-cart-filter-empty'),
                    onPressed: () {
                      ref.read(cartFilterProvider.notifier).clear();
                    },
                    icon: const Icon(Icons.filter_alt_off_rounded),
                    label: const Text('Limpiar filtro'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        key: ValueKey('cart-loading'),
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Cargando carrito…'),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        key: const ValueKey('cart-error'),
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 64, color: rosaPrincipal),
            const SizedBox(height: 16),
            const Text(
              'No pudimos cargar el carrito.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text('Inténtalo de nuevo.'),
            const SizedBox(height: 20),
            FilledButton.icon(
              key: const ValueKey('cart-retry-button'),
              onPressed: _retry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutBar(BuildContext context, CartSnapshot? snapshot) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasItems = snapshot != null && snapshot.allItems.isNotEmpty;

    return Material(
      color: colors.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasItems) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total', style: textTheme.titleMedium),
                    Text(
                      _formatPrice(snapshot.total),
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
                  onPressed: hasItems && !_hasPendingOperation
                      ? () => _continueToCheckout(snapshot)
                      : null,
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
    final cart = ref.watch(cartItemsProvider);
    final snapshot = cart.asData?.value;
    final body = _isSeeding
        ? _buildLoading()
        : _seedFailed
        ? _buildError()
        : cart.when(
            loading: _buildLoading,
            error: (error, stackTrace) => _buildError(),
            data: (data) {
              if (data.isEmpty) {
                return _buildEmptyCart(context);
              }
              if (data.hasNoVisibleItems) {
                return _buildFilteredEmpty(data);
              }
              return _buildItems(data);
            },
          );

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
      body: body,
      bottomNavigationBar: _buildCheckoutBar(
        context,
        _isSeeding || _seedFailed ? null : snapshot,
      ),
    );
  }
}

class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      decoration: BoxDecoration(
        color: rosaClaro,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Icon(
        Icons.delete_outline_rounded,
        color: rosaPrincipal,
        size: 28,
      ),
    );
  }
}
