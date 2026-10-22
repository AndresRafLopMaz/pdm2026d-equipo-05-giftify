import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/enums/gift_availability.dart';
import '../providers/product_filter_provider.dart';

/// Controles de filtro del catálogo de productos.
class ProductFilterBar extends ConsumerWidget {
  const ProductFilterBar({super.key});

  static const List<String> _categories = [
    'Joyería',
    'Alimentos',
    'Accesorios',
    'Artesanías',
    'Personalizados',
  ];

  static String _availabilityLabel(GiftAvailability availability) {
    return switch (availability) {
      GiftAvailability.inStock => 'Disponible',
      GiftAvailability.lowStock => 'Pocas unidades',
      GiftAvailability.outOfStock => 'Agotado',
      GiftAvailability.unknown => 'Por confirmar',
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(productFilterProvider);
    final notifier = ref.read(productFilterProvider.notifier);

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
            'Filtrar catálogo',
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
              FilterChip(
                key: const ValueKey('filter-category-all'),
                label: const Text('Todas'),
                selected: filter.category == null,
                onSelected: (_) => notifier.setCategory(null),
              ),
              for (final category in _categories)
                FilterChip(
                  key: ValueKey('filter-category-$category'),
                  label: Text(category),
                  selected: filter.category == category,
                  onSelected: (selected) {
                    notifier.setCategory(selected ? category : null);
                  },
                ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Disponibilidad',
            style: TextStyle(
              color: textoPrincipal,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterChip(
                key: const ValueKey('filter-availability-all'),
                label: const Text('Todas'),
                selected: filter.availability == null,
                onSelected: (_) => notifier.setAvailability(null),
              ),
              for (final availability in GiftAvailability.values)
                FilterChip(
                  key: ValueKey('filter-availability-${availability.name}'),
                  label: Text(_availabilityLabel(availability)),
                  selected: filter.availability == availability,
                  onSelected: (selected) {
                    notifier.setAvailability(selected ? availability : null);
                  },
                ),
            ],
          ),
          if (!filter.isEmpty) ...[
            const SizedBox(height: 4),
            TextButton.icon(
              key: const ValueKey('clear-product-filters'),
              onPressed: notifier.clear,
              icon: const Icon(Icons.filter_alt_off_rounded, size: 18),
              label: const Text('Limpiar filtros'),
            ),
          ],
        ],
      ),
    );
  }
}
