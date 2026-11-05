import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_router.dart';
import '../../../app/app_tab.dart';
import '../../../app/app_tab_notifier.dart';
import '../../../shared/enums/gift_availability.dart';
import '../../../shared/enums/gift_category.dart';
import '../../../shared/enums/gift_format.dart';
import '../../../shared/enums/gift_interest.dart';
import '../../../shared/enums/gift_occasion.dart';
import '../../../shared/enums/gift_recipient.dart';
import '../../../shared/enums/gift_size.dart';
import '../../../shared/models/gift_product.dart';
import '../../../shared/models/gift_search_criteria.dart';
import '../data/product_filter.dart';
import '../data/product_repository.dart';
import '../providers/product_filter_provider.dart';
import '../providers/products_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/product_filter_bar.dart';

class ProductResultsScreen extends ConsumerStatefulWidget {
  const ProductResultsScreen({super.key, this.criteria});

  final GiftSearchCriteria? criteria;

  @override
  ConsumerState<ProductResultsScreen> createState() =>
      _ProductResultsScreenState();
}

class _ProductResultsScreenState extends ConsumerState<ProductResultsScreen> {
  final Map<String, DeletedProduct> _pendingDeletions = {};

  void _retry() {
    ref.invalidate(productsProvider(widget.criteria));
  }

  void _modifySearch() {
    final navigator = Navigator.of(context);

    if (navigator.canPop()) {
      navigator.pop();
      return;
    }

    ref.read(appTabProvider.notifier).select(AppTab.search);
  }

  Future<void> _openFilters() {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: SingleChildScrollView(
            child: ProductFilterBar(onClose: () => Navigator.pop(sheetContext)),
          ),
        );
      },
    );
  }

  Future<bool> _confirmDelete(GiftProduct product) async {
    try {
      final deletion = await ref
          .read(productsProvider(widget.criteria).notifier)
          .deleteFromRepository(product.id);
      _pendingDeletions[product.id] = deletion;
      return true;
    } catch (_) {
      if (mounted) {
        _showMessage('No se pudo eliminar el producto. Inténtalo de nuevo.');
      }
      return false;
    }
  }

  void _onDismissed(GiftProduct product) {
    final deletion = _pendingDeletions.remove(product.id);

    if (deletion == null) {
      return;
    }

    ref.read(productsProvider(widget.criteria).notifier).removeLocal(deletion);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Producto eliminado.'),
        action: SnackBarAction(
          label: 'Deshacer',
          onPressed: () {
            ref
                .read(productsProvider(widget.criteria).notifier)
                .restore(deletion);
          },
        ),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(productFilterProvider);
    final products = ref.watch(productsProvider(widget.criteria));
    final horizontalPadding = MediaQuery.sizeOf(context).width >= 600
        ? 24.0
        : 16.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultados'),
        actions: [
          TextButton.icon(
            key: const ValueKey('results-filter-button'),
            onPressed: _openFilters,
            icon: const Icon(Icons.tune_rounded),
            label: const Text('Filtrar'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: products.when(
              loading: () => const _LoadingResults(),
              error: (error, stackTrace) => _ErrorResults(onRetry: _retry),
              data: (results) {
                if (results.isEmpty) {
                  return _EmptyResults(
                    hasFilters: !filter.isEmpty,
                    hasCriteria: widget.criteria != null,
                    onClearFilters: () {
                      ref.read(productFilterProvider.notifier).clear();
                    },
                    onModifySearch: _modifySearch,
                  );
                }

                return ListView(
                  key: const PageStorageKey('results-list'),
                  padding: const EdgeInsets.only(bottom: 24),
                  children: [
                    if (widget.criteria != null)
                      _CriteriaSummary(
                        criteria: widget.criteria!,
                        onChange: _modifySearch,
                        horizontalPadding: horizontalPadding,
                      )
                    else
                      _CatalogLabel(horizontalPadding: horizontalPadding),
                    if (!filter.isEmpty)
                      _ActiveFilters(
                        filter: filter,
                        horizontalPadding: horizontalPadding,
                        onClear: () {
                          ref.read(productFilterProvider.notifier).clear();
                        },
                      ),
                    for (var index = 0; index < results.length; index++) ...[
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                        ),
                        child: Dismissible(
                          key: ValueKey(results[index].id),
                          direction: DismissDirection.endToStart,
                          background: const _DeleteBackground(),
                          confirmDismiss: (_) => _confirmDelete(results[index]),
                          onDismissed: (_) => _onDismissed(results[index]),
                          child: ProductCard(
                            product: results[index],
                            onTap: () => _openDetail(context, results[index]),
                          ),
                        ),
                      ),
                      if (index < results.length - 1)
                        Divider(
                          indent: horizontalPadding,
                          endIndent: horizontalPadding,
                        ),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _openDetail(BuildContext context, GiftProduct product) {
    Navigator.pushNamed(context, AppRoutes.productDetail, arguments: product);
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

class _LoadingResults extends StatelessWidget {
  const _LoadingResults();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        key: const ValueKey('results-loading'),
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Cargando…',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorResults extends StatelessWidget {
  const _ErrorResults({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: Padding(
        key: const ValueKey('results-error'),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, color: colors.error, size: 48),
            const SizedBox(height: 16),
            Text(
              'No pudimos cargar los productos.',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Inténtalo de nuevo.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              key: const ValueKey('retry-button'),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CatalogLabel extends StatelessWidget {
  const _CatalogLabel({required this.horizontalPadding});

  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 20, horizontalPadding, 8),
      child: Text(
        'Catálogo',
        style: theme.textTheme.titleLarge?.copyWith(
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }
}

class _CriteriaSummary extends StatelessWidget {
  const _CriteriaSummary({
    required this.criteria,
    required this.onChange,
    required this.horizontalPadding,
  });

  final GiftSearchCriteria criteria;
  final VoidCallback onChange;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final parts = <String>[
      'Para ${criteria.recipientType.label}',
      criteria.occasion.label,
      if (criteria.interests.isNotEmpty)
        criteria.interests.map((interest) => interest.label).join(' + '),
      if (criteria.giftFormat != null) criteria.giftFormat!.label,
      if (criteria.size != null) criteria.size!.label,
      'hasta Q${criteria.maxBudget.toStringAsFixed(2)}',
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 16, horizontalPadding, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              parts.join(' · '),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            key: const ValueKey('criteria-change-button'),
            onPressed: onChange,
            child: const Text('Cambiar'),
          ),
        ],
      ),
    );
  }
}

class _ActiveFilters extends StatelessWidget {
  const _ActiveFilters({
    required this.filter,
    required this.horizontalPadding,
    required this.onClear,
  });

  final ProductFilter filter;
  final double horizontalPadding;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final parts = <String>[
      if (filter.category != null) filter.category!.label,
      if (filter.availability != null) _availabilityLabel(filter.availability!),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Filtros: ${parts.join(' · ')}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          TextButton(
            key: const ValueKey('clear-active-filters'),
            onPressed: onClear,
            child: const Text('Limpiar'),
          ),
        ],
      ),
    );
  }

  String _availabilityLabel(GiftAvailability availability) {
    return switch (availability) {
      GiftAvailability.inStock => 'Disponible',
      GiftAvailability.lowStock => 'Pocas unidades',
      GiftAvailability.outOfStock => 'Agotado',
      GiftAvailability.unknown => 'Por confirmar',
    };
  }
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults({
    required this.hasFilters,
    required this.hasCriteria,
    required this.onClearFilters,
    required this.onModifySearch,
  });

  final bool hasFilters;
  final bool hasCriteria;
  final VoidCallback onClearFilters;
  final VoidCallback onModifySearch;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: Padding(
        key: const ValueKey('results-empty'),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, color: colors.primary, size: 48),
            const SizedBox(height: 16),
            Text(
              'No encontramos productos.',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Prueba ajustando el presupuesto o las preferencias.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            if (hasFilters) ...[
              const SizedBox(height: 20),
              OutlinedButton.icon(
                key: const ValueKey('clear-product-filters-empty'),
                onPressed: onClearFilters,
                icon: const Icon(Icons.filter_alt_off_rounded),
                label: const Text('Limpiar filtros'),
              ),
            ],
            if (hasCriteria || !hasFilters) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                key: const ValueKey('modify-search-button'),
                onPressed: onModifySearch,
                icon: const Icon(Icons.tune_rounded),
                label: const Text('Modificar búsqueda'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
