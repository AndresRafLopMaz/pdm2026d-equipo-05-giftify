import 'package:flutter/material.dart';

import '../../../shared/models/delivery_address.dart';

enum AddressCardAction { edit, setDefault, archive, restore, delete }

class AddressCard extends StatelessWidget {
  const AddressCard({
    super.key,
    required this.address,
    required this.onEdit,
    required this.onSetDefault,
    required this.onArchive,
    required this.onRestore,
    required this.onDelete,
  });

  final DeliveryAddress address;
  final VoidCallback onEdit;
  final VoidCallback onSetDefault;
  final VoidCallback onArchive;
  final VoidCallback onRestore;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Semantics(
      button: !address.isArchived,
      hint: address.isArchived ? null : 'Editar dirección',
      child: InkWell(
        onTap: address.isArchived ? null : onEdit,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          address.label,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (address.isDefault && !address.isArchived)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colors.primaryContainer,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'Principal',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: colors.onPrimaryContainer,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      address.recipientName,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      address.addressLine,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${address.city}, ${address.department}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    if (address.reference != null &&
                        address.reference!.trim().isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Referencia: ${address.reference!.trim()}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 4),
              PopupMenuButton<AddressCardAction>(
                key: ValueKey('address-menu-${address.id}'),
                tooltip: 'Acciones de la dirección',
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: colors.onSurfaceVariant,
                ),
                onSelected: (action) {
                  switch (action) {
                    case AddressCardAction.edit:
                      onEdit();
                      break;
                    case AddressCardAction.setDefault:
                      onSetDefault();
                      break;
                    case AddressCardAction.archive:
                      onArchive();
                      break;
                    case AddressCardAction.restore:
                      onRestore();
                      break;
                    case AddressCardAction.delete:
                      onDelete();
                      break;
                  }
                },
                itemBuilder: (context) {
                  if (address.isArchived) {
                    return [
                      const PopupMenuItem(
                        value: AddressCardAction.restore,
                        child: ListTile(
                          leading: Icon(Icons.unarchive_outlined),
                          title: Text('Restaurar'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      PopupMenuItem(
                        value: AddressCardAction.delete,
                        child: ListTile(
                          leading: Icon(
                            Icons.delete_outline_rounded,
                            color: colors.error,
                          ),
                          title: Text(
                            'Eliminar',
                            style: TextStyle(color: colors.error),
                          ),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ];
                  }

                  return [
                    const PopupMenuItem(
                      value: AddressCardAction.edit,
                      child: ListTile(
                        leading: Icon(Icons.edit_outlined),
                        title: Text('Editar'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    if (!address.isDefault)
                      const PopupMenuItem(
                        value: AddressCardAction.setDefault,
                        child: ListTile(
                          leading: Icon(Icons.check_circle_outline_rounded),
                          title: Text('Usar como principal'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    const PopupMenuItem(
                      value: AddressCardAction.archive,
                      child: ListTile(
                        leading: Icon(Icons.archive_outlined),
                        title: Text('Archivar'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    PopupMenuItem(
                      value: AddressCardAction.delete,
                      child: ListTile(
                        leading: Icon(
                          Icons.delete_outline_rounded,
                          color: colors.error,
                        ),
                        title: Text(
                          'Eliminar',
                          style: TextStyle(color: colors.error),
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ];
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
