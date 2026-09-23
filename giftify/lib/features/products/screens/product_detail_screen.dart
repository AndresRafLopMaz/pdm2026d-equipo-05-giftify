import 'package:flutter/material.dart';

import '../../../shared/models/gift_product.dart';

/// Pantalla 5 — Detalle del producto.
///
/// Responsable principal: Andrés.
///
/// Recibe el producto seleccionado desde la pantalla de resultados.
class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key, this.product});

  final GiftProduct? product;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del producto')),
      body: const Center(child: Text('Detalle del producto')),
    );
  }
}
