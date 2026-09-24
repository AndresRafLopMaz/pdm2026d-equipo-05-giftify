import 'package:flutter/material.dart';

import '../../../app/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/data/mock_products.dart';
import '../../../shared/models/gift_product.dart';
import '../../../shared/models/gift_search_criteria.dart';
import '../utils/product_filters.dart';
import '../widgets/product_card.dart';

/// Pantalla 4 — Resultados personalizados.
///
/// Responsable principal: Andrés.
///
/// Recibe opcionalmente los criterios generados en la pantalla 3 y los
/// aplica sobre el catálogo local [mockProducts]. La navegación hacia el
/// detalle utiliza el contrato existente de [AppRoutes.productDetail].
class ProductResultsScreen extends StatelessWidget {
  const ProductResultsScreen({super.key, this.criteria});

  final GiftSearchCriteria? criteria;

  @override
  Widget build(BuildContext context) {
    final results = filterAndPrioritizeProducts(mockProducts, criteria);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultados'),
        backgroundColor: fondoPrincipal,
      ),
      body: SafeArea(
        child: results.isEmpty
            ? const _EmptyResults()
            : Column(
                children: [
                  if (criteria != null) _CriteriaSummary(criteria: criteria!),
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
              ),
      ),
    );
  }

  /// Abre el detalle enviando el producto por el contrato central de rutas.
  void _openDetail(BuildContext context, GiftProduct product) {
    Navigator.pushNamed(context, AppRoutes.productDetail, arguments: product);
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

/// Estado informativo cuando ningún producto cumple el presupuesto.
class _EmptyResults extends StatelessWidget {
  const _EmptyResults();

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
                Icons.search_off_rounded,
                color: verdePrincipal,
                size: 40,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No encontramos opciones que cumplan todos los criterios.',
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
          ],
        ),
      ),
    );
  }
}
