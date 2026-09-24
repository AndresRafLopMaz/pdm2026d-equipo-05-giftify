import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/enums/gift_availability.dart';

/// Representa visualmente el estado de disponibilidad de un producto.
///
/// Utiliza siempre texto e icono, además del color, para no depender
/// únicamente del color. Puede reutilizarse en la Pantalla 5.
class AvailabilityBadge extends StatelessWidget {
  const AvailabilityBadge({super.key, required this.availability});

  final GiftAvailability availability;

  @override
  Widget build(BuildContext context) {
    final style = _styleFor(availability);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, size: 15, color: style.foreground),
          const SizedBox(width: 5),
          Text(
            style.label,
            style: TextStyle(
              color: style.foreground,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeStyle {
  const _BadgeStyle({
    required this.label,
    required this.icon,
    required this.foreground,
    required this.background,
  });

  final String label;
  final IconData icon;
  final Color foreground;
  final Color background;
}

_BadgeStyle _styleFor(GiftAvailability availability) {
  switch (availability) {
    case GiftAvailability.inStock:
      return const _BadgeStyle(
        label: 'Disponible',
        icon: Icons.check_circle_rounded,
        foreground: verdeOscuro,
        background: verdeClaro,
      );

    case GiftAvailability.lowStock:
      return const _BadgeStyle(
        label: 'Pocas unidades',
        icon: Icons.inventory_2_outlined,
        foreground: Color(0xFFB0790A),
        background: Color(0xFFFFF5D8),
      );

    case GiftAvailability.outOfStock:
      return const _BadgeStyle(
        label: 'Agotado',
        icon: Icons.cancel_rounded,
        foreground: Color(0xFFB3261E),
        background: Color(0xFFFDECEA),
      );

    case GiftAvailability.unknown:
      return const _BadgeStyle(
        label: 'Por confirmar',
        icon: Icons.help_rounded,
        foreground: textoSecundario,
        background: Color(0xFFEDEFEE),
      );
  }
}
