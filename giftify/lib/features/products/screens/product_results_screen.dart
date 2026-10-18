import 'package:flutter/material.dart';

import '../../../app/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/gift_product.dart';
import '../../../shared/models/gift_search_criteria.dart';
import '../data/mock_product_repository.dart';
import '../data/product_repository.dart';
import '../utils/product_filters.dart';
import '../widgets/product_card.dart';

/// Pantalla 4 — Resultados personalizados.
///
/// Responsable principal: Andrés.
///
/// Recibe opcionalmente los criterios generados en la pantalla 3 y los aplica
/// sobre los productos obtenidos de un [ProductRepository]. Por defecto usa
/// [MockProductRepository] para conservar el MVP local.
class ProductResultsScreen extends StatefulWidget {
  const ProductResultsScreen({super.key, this.criteria, this.repository});

  final GiftSearchCriteria? criteria;
  final ProductRepository? repository;

  @override
  State<ProductResultsScreen> createState() => _ProductResultsScreenState();
}

class _ProductResultsScreenState extends State<ProductResultsScreen> {
  late final ProductRepository _repository;
  late Future<List<GiftProduct>> _resultsFuture;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? MockProductRepository();
    _resultsFuture = _loadResults();
  }

  Future<List<GiftProduct>> _loadResults() async {
    final products = await _repository.fetchProducts();
    return filterAndPrioritizeProducts(products, widget.criteria);
  }

  void _retry() {
    setState(() {
      _resultsFuture = _loadResults();
    });
  }

  void _modifySearch() {
    final navigator = Navigator.of(context);

    if (navigator.canPop()) {
      navigator.pop();
      return;
    }

    navigator.pushReplacementNamed(AppRoutes.search);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultados'),
        backgroundColor: fondoPrincipal,
      ),
      body: SafeArea(
        child: FutureBuilder<List<GiftProduct>>(
          future: _resultsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const _LoadingResults();
            }

            if (snapshot.hasError) {
              return _ErrorResults(onRetry: _retry);
            }

            final results = snapshot.data ?? const <GiftProduct>[];

            if (results.isEmpty) {
              return _EmptyResults(onModifySearch: _modifySearch);
            }

            return Column(
              children: [
                if (widget.criteria != null)
                  _CriteriaSummary(criteria: widget.criteria!),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    itemCount: results.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final product = results[index];

                      return ProductCard(
                        product: product,
                        onTap: () => _openDetail(context, product),
                      );
                    },
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
  const _EmptyResults({required this.onModifySearch});

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
            const SizedBox(height: 20),
            OutlinedButton.icon(
              key: const ValueKey('modify-search-button'),
              onPressed: onModifySearch,
              icon: const Icon(Icons.tune_rounded),
              label: const Text('Modificar búsqueda'),
            ),
          ],
        ),
      ),
    );
  }
}
