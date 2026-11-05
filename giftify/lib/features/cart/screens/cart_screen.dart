import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_router.dart';
import '../../../shared/models/cart_item.dart';
import '../data/cart_repository.dart';
import '../providers/cart_filter_provider.dart';
import '../providers/cart_items_provider.dart';

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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
    final colors = Theme.of(context).colorScheme;

    return Container(
      key: const ValueKey('product-image-placeholder'),
      width: 80,
      height: 80,
      color: colors.primaryContainer,
      alignment: Alignment.center,
      child: Icon(Icons.card_giftcard_rounded, color: colors.primary, size: 32),
    );
  }

  Widget _buildCartItem(BuildContext context, CartItem item) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final product = item.product;
    final isUpdating = _updatingIds.contains(product.id);
    final isDeleting = _deletingIds.contains(product.id);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
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
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colors.onSurface,
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
                      color: colors.error,
                      icon: const Icon(Icons.delete_outline_rounded),
                    ),
                  ],
                ),
                Text(
                  '${_formatPrice(product.price)} c/u',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _QuantityControl(
                      quantity: item.quantity,
                      onDecrease: item.quantity > 1 && !isUpdating
                          ? () => _changeQuantity(item, item.quantity - 1)
                          : null,
                      onIncrease: isUpdating
                          ? null
                          : () => _changeQuantity(item, item.quantity + 1),
                      productId: product.id,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Subtotal',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          _formatPrice(item.subtotal),
                          key: ValueKey('subtotal-${product.id}'),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colors.onSurface,
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
        ],
      ),
    );
  }

  Widget _buildFilters(CartSnapshot snapshot) {
    final selectedCategory = snapshot.filter.category;
    final categories = snapshot.categories.toList()..sort();

    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        children: [
          FilterChip(
            key: const ValueKey('cart-filter-all'),
            label: const Text('Todas'),
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
        for (var index = 0; index < snapshot.visibleItems.length; index++) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Dismissible(
              key: ValueKey(snapshot.visibleItems[index].product.id),
              direction: DismissDirection.endToStart,
              background: const _DeleteBackground(),
              confirmDismiss: (_) =>
                  _confirmDismiss(snapshot.visibleItems[index]),
              onDismissed: (_) => _onDismissed(snapshot.visibleItems[index]),
              child: _buildCartItem(context, snapshot.visibleItems[index]),
            ),
          ),
          if (index < snapshot.visibleItems.length - 1)
            const Divider(indent: 16, endIndent: 16),
        ],
      ],
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 48, color: colors.primary),
            const SizedBox(height: 16),
            Text(
              'Tu carrito está vacío',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Agrega un regalo para continuar con tu compra.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilteredEmpty(CartSnapshot snapshot) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      children: [
        _buildFilters(snapshot),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.filter_alt_off_rounded,
                    size: 48,
                    color: colors.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay productos en esta categoría.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
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
    final theme = Theme.of(context);

    return Center(
      child: Column(
        key: const ValueKey('cart-loading'),
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Cargando carrito…',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: Padding(
        key: const ValueKey('cart-error'),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 48, color: colors.error),
            const SizedBox(height: 16),
            Text(
              'No pudimos cargar el carrito.',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Inténtalo de nuevo.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final hasItems = snapshot != null && snapshot.allItems.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(16, 12, 16, 14),
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasItems) ...[
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Total',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colors.onSurface,
                          ),
                        ),
                      ),
                      Text(
                        _formatPrice(snapshot.total),
                        key: const ValueKey('cart-total'),
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w700,
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
                    child: const Text('Continuar al pago'),
                  ),
                ),
              ],
            ),
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
      appBar: AppBar(title: const Text('Carrito')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: constraints.maxWidth > 720 ? 720 : constraints.maxWidth,
                height: constraints.maxHeight,
                child: body,
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: _buildCheckoutBar(
        context,
        _isSeeding || _seedFailed ? null : snapshot,
      ),
    );
  }
}

class _QuantityControl extends StatelessWidget {
  const _QuantityControl({
    required this.quantity,
    required this.onDecrease,
    required this.onIncrease,
    required this.productId,
  });

  final int quantity;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;
  final String productId;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          key: ValueKey('decrease-$productId'),
          tooltip: 'Disminuir cantidad',
          onPressed: onDecrease,
          constraints: const BoxConstraints.tightFor(width: 44, height: 44),
          padding: EdgeInsets.zero,
          style: IconButton.styleFrom(
            backgroundColor: colors.surfaceContainer,
            foregroundColor: colors.primary,
            disabledBackgroundColor: colors.surfaceContainerHighest,
            disabledForegroundColor: colors.onSurfaceVariant,
          ),
          icon: const Icon(Icons.remove_rounded),
        ),
        SizedBox(
          width: 36,
          child: Text(
            '$quantity',
            key: ValueKey('quantity-$productId'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        IconButton(
          key: ValueKey('increase-$productId'),
          tooltip: 'Aumentar cantidad',
          onPressed: onIncrease,
          constraints: const BoxConstraints.tightFor(width: 44, height: 44),
          padding: EdgeInsets.zero,
          style: IconButton.styleFrom(
            backgroundColor: colors.surfaceContainer,
            foregroundColor: colors.primary,
            disabledBackgroundColor: colors.surfaceContainerHighest,
            disabledForegroundColor: colors.onSurfaceVariant,
          ),
          icon: const Icon(Icons.add_rounded),
        ),
      ],
    );
  }
}

class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      color: colors.errorContainer,
      child: Icon(Icons.delete_outline_rounded, color: colors.error, size: 28),
    );
  }
}
