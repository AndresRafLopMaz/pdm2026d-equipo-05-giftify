import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
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
    return Card(
      elevation: 0,
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFE4E8E6)),
      ),
      child: InkWell(
        onTap: address.isArchived ? null : onEdit,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          address.label,
                          style: const TextStyle(
                            color: textoPrincipal,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (address.isDefault && !address.isArchived)
                          const _Badge(
                            label: 'Principal',
                            background: verdeClaro,
                            foreground: verdeOscuro,
                          ),
                        if (address.isArchived)
                          const _Badge(
                            label: 'Archivada',
                            background: Color(0xFFF1F2F2),
                            foreground: textoSecundario,
                          ),
                      ],
                    ),
                  ),
                  PopupMenuButton<AddressCardAction>(
                    key: ValueKey('address-menu-${address.id}'),
                    tooltip: 'Acciones de la dirección',
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
                        return const [
                          PopupMenuItem(
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
                              leading: Icon(Icons.delete_outline_rounded),
                              title: Text('Eliminar'),
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
                        const PopupMenuItem(
                          value: AddressCardAction.delete,
                          child: ListTile(
                            leading: Icon(Icons.delete_outline_rounded),
                            title: Text('Eliminar'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ];
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                address.recipientName,
                style: const TextStyle(
                  color: textoPrincipal,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                address.addressLine,
                style: const TextStyle(
                  color: textoSecundario,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${address.city}, ${address.department}',
                style: const TextStyle(color: textoSecundario, fontSize: 14),
              ),
              if (address.reference != null &&
                  address.reference!.trim().isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  'Referencia: ${address.reference!.trim()}',
                  style: const TextStyle(
                    color: textoSecundario,
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
