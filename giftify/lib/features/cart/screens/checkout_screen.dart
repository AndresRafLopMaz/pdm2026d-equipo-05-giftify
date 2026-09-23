import 'package:flutter/material.dart';

import '../../../shared/models/cart_item.dart';

/// Pantalla 7 — Check-out.
///
/// Responsable principal: Catherine.
///
/// Recibe los elementos confirmados en el carrito.
/// La dirección y el método de pago se manejarán dentro de este módulo.
class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key, this.items = const []});

  final List<CartItem> items;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Check-out')),
      body: const Center(child: Text('Check-out')),
    );
  }
}
