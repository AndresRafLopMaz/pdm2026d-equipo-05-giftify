import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/enums/gift_availability.dart';

class AvailabilityBadge extends StatelessWidget {
  const AvailabilityBadge({super.key, required this.availability});

  final GiftAvailability availability;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final giftify = GiftifyColors.of(context);
    final style = _styleFor(colors, giftify, availability);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, size: 14, color: style.foreground),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              style.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: style.foreground,
                fontSize: 12,
                height: 1.33,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _BadgeStyle _styleFor(
    ColorScheme colors,
    GiftifyColors giftify,
    GiftAvailability availability,
  ) {
    return switch (availability) {
      GiftAvailability.inStock => _BadgeStyle(
        label: 'Disponible',
        icon: Icons.check_circle_rounded,
        foreground: giftify.successStrong,
        background: giftify.successSoft,
      ),
      GiftAvailability.lowStock => _BadgeStyle(
        label: 'Pocas unidades',
        icon: Icons.inventory_2_outlined,
        foreground: giftify.warmStrong,
        background: giftify.warmSoft,
      ),
      GiftAvailability.outOfStock => _BadgeStyle(
        label: 'Agotado',
        icon: Icons.cancel_rounded,
        foreground: colors.error,
        background: colors.errorContainer,
      ),
      GiftAvailability.unknown => _BadgeStyle(
        label: 'Por confirmar',
        icon: Icons.help_rounded,
        foreground: colors.onSurfaceVariant,
        background: colors.surfaceContainerHighest,
      ),
    };
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
