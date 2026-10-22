import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_router.dart';
import '../../../app/app_tab.dart';
import '../../../app/app_tab_notifier.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/gift_product.dart';
import '../../../shared/models/gift_search_criteria.dart';
import '../data/product_repository.dart';
import '../providers/product_filter_provider.dart';
import '../providers/products_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/product_filter_bar.dart';

/// Pantalla 4 — Resultados personalizados.
///
/// Responsable principal: Andrés.
///
/// Los criterios de búsqueda siguen llegando por el router. El catálogo puede
/// refinarse además con [ProductFilter], gestionado por Riverpod.
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(productFilterProvider);
    final products = ref.watch(productsProvider(widget.criteria));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultados'),
        backgroundColor: fondoPrincipal,
      ),
      body: SafeArea(
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
                  _CriteriaSummary(criteria: widget.criteria!),
                const ProductFilterBar(),
                const SizedBox(height: 12),
                for (final product in results)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Dismissible(
                      key: ValueKey(product.id),
                      direction: DismissDirection.endToStart,
                      background: const _DeleteBackground(),
                      confirmDismiss: (_) => _confirmDelete(product),
                      onDismissed: (_) => _onDismissed(product),
                      child: ProductCard(
                        product: product,
                        onTap: () => _openDetail(context, product),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Abre el detalle enviando el producto por el contrato central de rutas.
  void _openDetail(BuildContext context, GiftProduct product) {
    Navigator.pushNamed(context, AppRoutes.productDetail, arguments: product);
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

/// Estado de carga mientras el repositorio responde.
class _LoadingResults extends StatelessWidget {
  const _LoadingResults();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        key: ValueKey('results-loading'),
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Cargando…',
            style: TextStyle(color: textoPrincipal, fontSize: 15),
          ),
        ],
      ),
    );
  }
}

/// Estado de error con reintento manual.
class _ErrorResults extends StatelessWidget {
  const _ErrorResults({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        key: const ValueKey('results-error'),
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: rosaClaro,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                color: rosaPrincipal,
                size: 40,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No pudimos cargar los productos.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textoPrincipal,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Inténtalo de nuevo.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textoSecundario,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
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

/// Resumen breve de los criterios utilizados en la búsqueda.
class _CriteriaSummary extends StatelessWidget {
  const _CriteriaSummary({required this.criteria});

  final GiftSearchCriteria criteria;

  @override
  Widget build(BuildContext context) {
    final giftType = criteria.giftType;
    final size = criteria.size;

    final tags = <String>[
      criteria.occasion.trim(),
      criteria.recipient.trim(),
      if (giftType != null && giftType.trim().isNotEmpty) giftType.trim(),
      if (size != null && size.trim().isNotEmpty) size.trim(),
      'Hasta Q ${criteria.maxBudget.toStringAsFixed(2)}',
    ];

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4E8E6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tu búsqueda',
            style: TextStyle(
              color: textoPrincipal,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final tag in tags)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: verdeClaro,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(
                      color: verdeOscuro,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Estado informativo cuando no hay productos que mostrar.
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
    return Center(
      child: Padding(
        key: const ValueKey('results-empty'),
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
                Icons.search_off_rounded,
                color: verdePrincipal,
                size: 40,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No encontramos productos.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textoPrincipal,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Prueba ajustando el presupuesto o las preferencias.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textoSecundario,
                fontSize: 14,
                height: 1.4,
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
