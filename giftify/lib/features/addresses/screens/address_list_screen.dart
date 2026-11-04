import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/models/delivery_address.dart';
import '../data/address_book.dart';
import '../data/address_repository.dart';
import '../providers/addresses_provider.dart';
import '../widgets/address_card.dart';
import 'address_form_screen.dart';

enum _InUseAction { archive, changeDefault }

class AddressListScreen extends ConsumerStatefulWidget {
  const AddressListScreen({super.key});

  @override
  ConsumerState<AddressListScreen> createState() => _AddressListScreenState();
}

class _AddressListScreenState extends ConsumerState<AddressListScreen> {
  bool _showArchived = false;

  void _retry() {
    ref.invalidate(addressesProvider);
  }

  Future<void> _refreshAddresses() async {
    ref.invalidate(addressesProvider);
    await ref.read(addressesProvider.future);
  }

  Future<void> _openCreate() async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => AddressFormScreen(
          onSubmit: (draft) async {
            await ref.read(addressesProvider.notifier).createAddress(draft);
            await _refreshAddresses();
          },
        ),
      ),
    );

    if (mounted) {
      setState(() => _showArchived = false);
    }
  }

  Future<void> _openEdit(DeliveryAddress address) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => AddressFormScreen(
          initialAddress: address,
          onSubmit: (draft) async {
            await ref
                .read(addressesProvider.notifier)
                .updateAddress(address.id, draft);
            await _refreshAddresses();
          },
        ),
      ),
    );
  }

  Future<void> _setDefault(DeliveryAddress address) async {
    await _run(
      () => ref.read(addressesProvider.notifier).setDefaultAddress(address.id),
      'Dirección principal actualizada.',
    );
  }

  Future<void> _archive(DeliveryAddress address) async {
    await _run(
      () => ref.read(addressesProvider.notifier).archiveAddress(address.id),
      'Dirección archivada.',
    );
  }

  Future<void> _restore(DeliveryAddress address) async {
    await _run(
      () => ref.read(addressesProvider.notifier).restoreAddress(address.id),
      'Dirección restaurada.',
    );
  }

  Future<void> _delete(DeliveryAddress address) async {
    try {
      await ref.read(addressesProvider.notifier).deleteAddress(address.id);
      await _refreshAddresses();
      if (mounted) {
        _showMessage('Dirección eliminada.');
      }
    } on AddressInUseException catch (error) {
      if (mounted) {
        await _showInUseDialog(address, error.message);
      }
    } on AddressException catch (error) {
      if (mounted) {
        _showMessage(error.message);
      }
    } catch (_) {
      if (mounted) {
        _showMessage('No pudimos eliminar la dirección. Inténtalo de nuevo.');
      }
    }
  }

  Future<void> _run(Future<void> Function() action, String message) async {
    try {
      await action();
      await _refreshAddresses();
      if (mounted) {
        _showMessage(message);
      }
    } on AddressException catch (error) {
      if (mounted) {
        _showMessage(error.message);
      }
    } catch (_) {
      if (mounted) {
        _showMessage('No pudimos completar la acción. Inténtalo de nuevo.');
      }
    }
  }

  Future<void> _showInUseDialog(DeliveryAddress address, String message) async {
    final action = await showDialog<_InUseAction>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Dirección en uso'),
          content: Text(
            '$message\n\n'
            'Puedes cambiar la dirección principal o archivarla.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              key: const ValueKey('in-use-archive'),
              onPressed: () =>
                  Navigator.of(dialogContext).pop(_InUseAction.archive),
              child: const Text('Archivar'),
            ),
            FilledButton(
              key: const ValueKey('in-use-change-default'),
              onPressed: () =>
                  Navigator.of(dialogContext).pop(_InUseAction.changeDefault),
              child: const Text('Cambiar principal'),
            ),
          ],
        );
      },
    );

    if (!mounted || action == null) {
      return;
    }

    switch (action) {
      case _InUseAction.archive:
        await _archive(address);
        break;
      case _InUseAction.changeDefault:
        await _chooseNewDefault(address);
        break;
    }
  }

  Future<void> _chooseNewDefault(DeliveryAddress current) async {
    final book = ref.read(addressesProvider).asData?.value;
    final candidates = book == null
        ? const <DeliveryAddress>[]
        : book.active.where((address) => address.id != current.id).toList();

    if (candidates.isEmpty) {
      _showMessage('No hay otra dirección activa para usar como principal.');
      return;
    }

    final selectedId = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return SimpleDialog(
          title: const Text('Elegir dirección principal'),
          children: [
            for (final candidate in candidates)
              ListTile(
                key: ValueKey('choose-default-${candidate.id}'),
                leading: const Icon(
                  Icons.location_on_outlined,
                  color: verdePrincipal,
                ),
                title: Text(candidate.label),
                subtitle: Text(candidate.recipientName),
                onTap: () => Navigator.of(dialogContext).pop(candidate.id),
              ),
          ],
        );
      },
    );

    if (selectedId == null || !mounted) {
      return;
    }

    await _run(
      () => ref.read(addressesProvider.notifier).setDefaultAddress(selectedId),
      'Dirección principal actualizada.',
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final addresses = ref.watch(addressesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis direcciones'),
        backgroundColor: fondoPrincipal,
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const ValueKey('add-address-button'),
        onPressed: _openCreate,
        backgroundColor: verdePrincipal,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nueva dirección'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: SegmentedButton<bool>(
                segments: const [
                  ButtonSegment<bool>(
                    value: false,
                    label: Text(
                      'Activas',
                      key: ValueKey('addresses-tab-active'),
                    ),
                    icon: Icon(Icons.check_circle_outline_rounded),
                  ),
                  ButtonSegment<bool>(
                    value: true,
                    label: Text(
                      'Archivadas',
                      key: ValueKey('addresses-tab-archived'),
                    ),
                    icon: Icon(Icons.archive_outlined),
                  ),
                ],
                selected: {_showArchived},
                onSelectionChanged: (selection) {
                  setState(() => _showArchived = selection.first);
                },
              ),
            ),
            Expanded(
              child: addresses.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    key: ValueKey('addresses-loading'),
                  ),
                ),
                error: (_, _) => _AddressError(onRetry: _retry),
                data: (book) => _buildBook(book),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBook(AddressBook book) {
    final visible = _showArchived ? book.archived : book.active;

    if (visible.isEmpty) {
      return _AddressEmpty(showArchived: _showArchived);
    }

    return ListView.separated(
      key: const PageStorageKey('addresses-list'),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 110),
      itemCount: visible.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final address = visible[index];
        return AddressCard(
          key: ValueKey('address-card-${address.id}'),
          address: address,
          onEdit: () => _openEdit(address),
          onSetDefault: () => _setDefault(address),
          onArchive: () => _archive(address),
          onRestore: () => _restore(address),
          onDelete: () => _delete(address),
        );
      },
    );
  }
}

class _AddressEmpty extends StatelessWidget {
  const _AddressEmpty({required this.showArchived});

  final bool showArchived;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        key: const ValueKey('addresses-empty'),
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: verdeClaro,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                showArchived
                    ? Icons.inventory_2_outlined
                    : Icons.location_on_outlined,
                color: verdePrincipal,
                size: 38,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              showArchived
                  ? 'No hay direcciones archivadas.'
                  : 'No tienes direcciones activas.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: textoPrincipal,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              showArchived
                  ? 'Las direcciones que archives aparecerán aquí.'
                  : 'Agrega una dirección para usarla en tus entregas.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: textoSecundario,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressError extends StatelessWidget {
  const _AddressError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        key: const ValueKey('addresses-error'),
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: rosaClaro,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                color: rosaPrincipal,
                size: 38,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No pudimos cargar tus direcciones.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textoPrincipal,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Inténtalo de nuevo.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textoSecundario,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              key: const ValueKey('retry-addresses'),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
