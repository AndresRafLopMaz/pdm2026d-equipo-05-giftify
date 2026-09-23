import 'package:flutter/material.dart';

import '../../../shared/models/cart_item.dart';

/// Pantalla 6 — Carrito de compras.
///
/// Responsable principal: Catherine.
///
/// La lista inicial permite recibir productos seleccionados desde
/// otras pantallas sin definir todavía un gestor global de estado.
class CartScreen extends StatelessWidget {
  const CartScreen({super.key, this.initialItems = const []});

  final List<CartItem> initialItems;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Carrito')),
      body: const Center(child: Text('Carrito')),
    );
  }
}
