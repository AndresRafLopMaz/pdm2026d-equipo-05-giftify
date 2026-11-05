import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_router.dart';
import '../../../app/app_tab.dart';
import '../../../app/app_tab_notifier.dart';
import '../models/checkout_success_data.dart';

class CheckoutSuccessScreen extends ConsumerWidget {
  const CheckoutSuccessScreen({super.key, required this.data});

  final CheckoutSuccessData data;

  String _formatPrice(double price) => 'Q ${price.toStringAsFixed(2)}';

  void _goHome(BuildContext context, WidgetRef ref) {
    ref.read(appTabProvider.notifier).select(AppTab.home);
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    } else {
      navigator.pushReplacementNamed(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final unitsLabel = data.totalUnits == 1
        ? '1 artículo'
        : '${data.totalUnits} artículos';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _goHome(context, ref);
        }
      },
      child: Scaffold(
        key: const ValueKey('checkout-success-screen'),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Confirmación'),
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 72,
                      color: colors.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Pedido confirmado',
                      key: const ValueKey('checkout-success-title'),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tu carrito se vació correctamente. '
                      'Esta compra es una simulación académica; no se procesó '
                      'un pago real ni se creó una orden de compra.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _SummaryRow(label: 'Productos', value: unitsLabel),
                            const SizedBox(height: 10),
                            _SummaryRow(
                              label: 'Total',
                              value: _formatPrice(data.total),
                              valueKey: const ValueKey(
                                'checkout-success-total',
                              ),
                            ),
                            const Divider(height: 28),
                            _SummaryRow(
                              label: 'Entrega',
                              value:
                                  '${data.addressLabel} · ${data.recipientName}',
                            ),
                            const SizedBox(height: 10),
                            _SummaryRow(
                              label: 'Pago',
                              value:
                                  '${data.paymentBrand.label} '
                                  '•••• ${data.paymentLast4}',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'No se guardaron datos de tarjeta ni se creó una '
                        'orden de compra.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      key: const ValueKey('checkout-success-home-button'),
                      onPressed: () => _goHome(context, ref),
                      icon: const Icon(Icons.home_rounded),
                      label: const Text('Volver al inicio'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value, this.valueKey});

  final String label;
  final String value;
  final Key? valueKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            key: valueKey,
            textAlign: TextAlign.end,
            style: theme.textTheme.titleSmall?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
