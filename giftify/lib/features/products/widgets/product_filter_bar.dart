import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/enums/gift_availability.dart';
import '../providers/product_filter_provider.dart';

class ProductFilterBar extends ConsumerWidget {
  const ProductFilterBar({super.key, this.onClose});

  static const List<String> _categories = [
    'Joyería',
    'Alimentos',
    'Accesorios',
    'Artesanías',
    'Personalizados',
  ];

  final VoidCallback? onClose;

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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final filter = ref.watch(productFilterProvider);
    final notifier = ref.read(productFilterProvider.notifier);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Filtros',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colors.onSurface,
                  ),
                ),
              ),
              if (onClose != null)
                IconButton(
                  key: const ValueKey('filters-close-button'),
                  tooltip: 'Cerrar filtros',
                  onPressed: onClose,
                  icon: const Icon(Icons.close_rounded),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Categoría',
            style: theme.textTheme.labelMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
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
          const SizedBox(height: 16),
          Text(
            'Disponibilidad',
            style: theme.textTheme.labelMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
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
            const SizedBox(height: 8),
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
