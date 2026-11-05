import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_router.dart';
import '../../../shared/models/payment_method.dart';
import '../providers/payment_methods_provider.dart';
import '../widgets/payment_demo_notice.dart';

class PaymentMethodsScreen extends ConsumerWidget {
  const PaymentMethodsScreen({super.key});

  Future<void> _openAdd(BuildContext context, WidgetRef ref) async {
    final added = await Navigator.pushNamed(
      context,
      AppRoutes.addPaymentMethod,
    );
    if (added == true && context.mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Método de pago agregado.')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final methods = ref.watch(paymentMethodsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Métodos de pago')),
      floatingActionButton: methods.hasValue && methods.requireValue.isNotEmpty
          ? FloatingActionButton.extended(
              key: const ValueKey('payment-add-button'),
              onPressed: () => _openAdd(context, ref),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Agregar'),
            )
          : null,
      body: SafeArea(
        child: methods.when(
          loading: () => const Center(
            child: CircularProgressIndicator(key: ValueKey('payments-loading')),
          ),
          error: (_, _) => _PaymentError(
            onRetry: () => ref.invalidate(paymentMethodsProvider),
          ),
          data: (items) {
            if (items.isEmpty) {
              return _EmptyPayments(onAdd: () => _openAdd(context, ref));
            }

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                  children: [
                    const PaymentDemoNotice(),
                    const SizedBox(height: 16),
                    for (final method in items) ...[
                      _PaymentMethodCard(
                        method: method,
                        onSetDefault: () => _setDefault(context, ref, method),
                        onDelete: () => _confirmDelete(context, ref, method),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _setDefault(
    BuildContext context,
    WidgetRef ref,
    PaymentMethod method,
  ) async {
    try {
      await ref.read(paymentMethodsProvider.notifier).setDefault(method.id);
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No pudimos actualizar el método predeterminado.'),
        ),
      );
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    PaymentMethod method,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final colors = Theme.of(dialogContext).colorScheme;
        return AlertDialog(
          title: const Text('¿Eliminar método de pago?'),
          content: Text('${method.brand.label} ${method.maskedNumber}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              key: const ValueKey('payment-delete-confirm'),
              onPressed: () => Navigator.pop(dialogContext, true),
              style: TextButton.styleFrom(foregroundColor: colors.error),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    try {
      await ref.read(paymentMethodsProvider.notifier).delete(method.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Método de pago eliminado.')),
        );
      }
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No pudimos eliminar el método de pago.')),
      );
    }
  }
}

class _PaymentMethodCard extends StatelessWidget {
  const _PaymentMethodCard({
    required this.method,
    required this.onSetDefault,
    required this.onDelete,
  });

  final PaymentMethod method;
  final VoidCallback onSetDefault;
  final VoidCallback onDelete;

  bool get _isExpired {
    final now = DateTime.now();
    return method.expiryYear < now.year ||
        (method.expiryYear == now.year && method.expiryMonth < now.month);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final expired = _isExpired;

    return Card(
      key: ValueKey('payment-method-${method.id}'),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        leading: Icon(Icons.credit_card_rounded, color: colors.primary),
        title: Text(
          '${method.brand.label} ${method.maskedNumber}',
          style: theme.textTheme.titleMedium?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Vence ${method.expiryLabel}'),
            if (expired)
              Row(
                key: ValueKey('payment-expired-${method.id}'),
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 14,
                    color: colors.error,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Vencido',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colors.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            if (method.isDefault)
              Text(
                'Predeterminado',
                key: const ValueKey('payment-default-label'),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ),
        trailing: PopupMenuButton<_PaymentAction>(
          key: ValueKey('payment-menu-${method.id}'),
          tooltip: 'Opciones del método de pago',
          onSelected: (action) {
            switch (action) {
              case _PaymentAction.setDefault:
                onSetDefault();
              case _PaymentAction.delete:
                onDelete();
            }
          },
          itemBuilder: (context) => [
            if (!method.isDefault)
              const PopupMenuItem(
                value: _PaymentAction.setDefault,
                child: Text('Establecer como predeterminado'),
              ),
            const PopupMenuItem(
              value: _PaymentAction.delete,
              child: Text('Eliminar'),
            ),
          ],
        ),
      ),
    );
  }
}

enum _PaymentAction { setDefault, delete }

class _EmptyPayments extends StatelessWidget {
  const _EmptyPayments({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.credit_card_off_rounded,
                size: 48,
                color: colors.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Aún no tienes métodos de pago',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Agrega un método ficticio para identificar tus pagos '
                'en esta demostración.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                key: const ValueKey('payment-add-button'),
                onPressed: onAdd,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Agregar método de pago'),
              ),
              const SizedBox(height: 20),
              const PaymentDemoNotice(),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentError extends StatelessWidget {
  const _PaymentError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 48, color: colors.error),
            const SizedBox(height: 12),
            Text(
              'No pudimos cargar tus métodos de pago.',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              key: const ValueKey('payments-retry'),
              onPressed: onRetry,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
