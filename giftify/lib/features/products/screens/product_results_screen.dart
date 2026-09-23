import 'package:flutter/material.dart';

import '../../../shared/models/gift_search_criteria.dart';

/// Pantalla 4 — Resultados personalizados.
///
/// Responsable principal: Andrés.
///
/// Recibe opcionalmente los criterios generados en la pantalla 3.
/// La implementación visual y la lógica de filtrado se desarrollarán
/// posteriormente en la rama correspondiente.
class ProductResultsScreen extends StatelessWidget {
  const ProductResultsScreen({super.key, this.criteria});

  final GiftSearchCriteria? criteria;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resultados')),
      body: const Center(child: Text('Resultados')),
    );
  }
}
