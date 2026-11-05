import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_router.dart';
import '../../../app/app_tab.dart';
import '../../../app/app_tab_notifier.dart';
import '../../../shared/models/delivery_address.dart';
import '../../../shared/models/payment_method.dart';
import '../../addresses/data/address_book.dart';
import '../../addresses/providers/addresses_provider.dart';
import '../../checkout/models/checkout_success_data.dart';
import '../../payments/providers/payment_methods_provider.dart';
import '../providers/cart_items_provider.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key, this.now});

  /// Fecha usada para validar el vencimiento de los métodos de pago.
  final DateTime? now;

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  late final DateTime _now;
  String? _selectedAddressId;
  String? _selectedPaymentId;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _now = widget.now ?? DateTime.now();
  }

  String _formatPrice(double price) => 'Q ${price.toStringAsFixed(2)}';

  bool _isExpired(PaymentMethod method) {
    return method.expiryYear < _now.year ||
        (method.expiryYear == _now.year && method.expiryMonth < _now.month);
  }

  DeliveryAddress? _resolveAddress(AddressBook book) {
    final active = book.addresses
        .where((address) => !address.isArchived)
        .toList(growable: false);
    if (active.isEmpty) {
      return null;
    }

    for (final address in active) {
      if (address.id == _selectedAddressId) {
        return address;
      }
    }

    for (final address in active) {
      if (address.isDefault) {
        return address;
      }
    }

    return active.first;
  }

  PaymentMethod? _resolvePayment(List<PaymentMethod> methods) {
    PaymentMethod? selected;
    for (final method in methods) {
      if (method.id == _selectedPaymentId) {
        selected = method;
        break;
      }
    }

    if (selected != null && !_isExpired(selected)) {
      return selected;
    }

    for (final method in methods) {
      if (method.isDefault && !_isExpired(method)) {
        return method;
      }
    }

    for (final method in methods) {
      if (!_isExpired(method)) {
        return method;
      }
    }

    return selected ?? (methods.isEmpty ? null : methods.first);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _goHome() {
    ref.read(appTabProvider.notifier).select(AppTab.home);
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    } else {
      navigator.pushReplacementNamed(AppRoutes.home);
    }
  }

  Future<void> _openAddressSelector(AddressBook book) async {
    final active = book.addresses
        .where((address) => !address.isArchived)
        .toList(growable: false);
    if (active.isEmpty) {
      await Navigator.pushNamed(context, AppRoutes.addresses);
      return;
    }

    final current = _resolveAddress(book);
    final selectedId = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.7,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const ListTile(
                    title: Text('Seleccionar dirección'),
                    subtitle: Text('Usaremos estos datos para la entrega.'),
                  ),
                  RadioGroup<String>(
                    groupValue: current?.id,
                    onChanged: (value) {
                      if (value != null) {
                        Navigator.pop(sheetContext, value);
                      }
                    },
                    child: Column(
                      children: [
                        for (final address in active)
                          RadioListTile<String>(
                            value: address.id,
                            title: Text(address.label),
                            subtitle: Text(
                              '${address.recipientName} · '
                              '${address.addressLine}, ${address.city}'
                              '${address.isDefault ? ' · Principal' : ''}',
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (selectedId != null && mounted) {
      setState(() => _selectedAddressId = selectedId);
    }
  }

  Future<void> _openPaymentSelector(List<PaymentMethod> methods) async {
    if (methods.isEmpty) {
      await Navigator.pushNamed(context, AppRoutes.addPaymentMethod);
      return;
    }

    final current = _resolvePayment(methods);
    final selectedId = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.7,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const ListTile(
                    title: Text('Seleccionar método de pago'),
                    subtitle: Text('Solo se muestran datos ficticios.'),
                  ),
                  RadioGroup<String>(
                    groupValue: current?.id,
                    onChanged: (value) {
                      if (value != null) {
                        Navigator.pop(sheetContext, value);
                      }
                    },
                    child: Column(
                      children: [
                        for (final method in methods)
                          RadioListTile<String>(
                            value: method.id,
                            enabled: !_isExpired(method),
                            title: Text(
                              '${method.brand.label} ${method.maskedNumber}',
                            ),
                            subtitle: Text(
                              _isExpired(method)
                                  ? 'Vence ${method.expiryLabel} · Vencido'
                                  : 'Vence ${method.expiryLabel}'
                                        '${method.isDefault ? ' · Predeterminado' : ''}',
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (selectedId != null && mounted) {
      setState(() => _selectedPaymentId = selectedId);
    }
  }

  Future<void> _addAddress() async {
    await Navigator.pushNamed(context, AppRoutes.addresses);
  }

  Future<void> _addPaymentMethod() async {
    await Navigator.pushNamed(context, AppRoutes.addPaymentMethod);
  }

  Future<void> _confirmOrder() async {
    if (_isSubmitting) {
      return;
    }

    final cart = ref.read(cartItemsProvider).asData?.value;
    final book = ref.read(addressesProvider).asData?.value;
    final methods = ref.read(paymentMethodsProvider).asData?.value;
    if (cart == null || cart.isEmpty || book == null || methods == null) {
      return;
    }

    final address = _resolveAddress(book);
    final payment = _resolvePayment(methods);
    if (address == null ||
        payment == null ||
        _isExpired(payment) ||
        cart.allItems.isEmpty) {
      return;
    }

    final totalUnits = cart.allItems.fold<int>(
      0,
      (total, item) => total + item.quantity,
    );
    final successData = CheckoutSuccessData(
      totalUnits: totalUnits,
      total: cart.total,
      addressLabel: address.label,
      recipientName: address.recipientName,
      paymentBrand: payment.brand,
      paymentLast4: payment.last4,
    );

    setState(() => _isSubmitting = true);

    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (!mounted) {
      return;
    }

    try {
      await ref.read(cartItemsProvider.notifier).clear();
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _isSubmitting = false);
      _showMessage(
        'No pudimos vaciar el carrito. Tu compra no se completó; '
        'inténtalo de nuevo.',
      );
      return;
    }

    if (!mounted) {
      return;
    }

    await Navigator.pushReplacementNamed(
      context,
      AppRoutes.checkoutSuccess,
      arguments: successData,
    );
  }

  void _retry() {
    ref.invalidate(cartItemsProvider);
    ref.invalidate(addressesProvider);
    ref.invalidate(paymentMethodsProvider);
  }

  Widget _buildLoading() {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        key: const ValueKey('checkout-loading'),
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Preparando tu compra…',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: Padding(
        key: const ValueKey('checkout-error'),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 48, color: colors.error),
            const SizedBox(height: 16),
            Text(
              'No pudimos preparar el checkout.',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Revisa tu conexión e inténtalo de nuevo.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              key: const ValueKey('checkout-retry'),
              onPressed: _retry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCheckout() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: Padding(
        key: const ValueKey('checkout-empty'),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.remove_shopping_cart_outlined,
              size: 48,
              color: colors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Tu carrito está vacío',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Agrega un regalo antes de finalizar la compra.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              key: const ValueKey('checkout-empty-home'),
              onPressed: _goHome,
              icon: const Icon(Icons.home_rounded),
              label: const Text('Volver al inicio'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    final theme = Theme.of(context);

    return Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(
        color: theme.colorScheme.onSurface,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _selectionPanel({
    required IconData icon,
    required String title,
    required String subtitle,
    String? detail,
    required String changeLabel,
    required VoidCallback onChange,
    Key? cardKey,
    Key? changeKey,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      key: cardKey,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                if (detail != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    detail,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurface,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            key: changeKey,
            onPressed: _isSubmitting ? null : onChange,
            child: Text(changeLabel),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSection(AddressBook book) {
    final address = _resolveAddress(book);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionTitle('Entrega'),
        const SizedBox(height: 10),
        if (address == null)
          _selectionPanel(
            icon: Icons.location_off_outlined,
            title: 'Sin dirección guardada',
            subtitle: 'Agrega una dirección para continuar.',
            changeLabel: 'Agregar',
            changeKey: const ValueKey('checkout-address-add'),
            onChange: _addAddress,
            cardKey: const ValueKey('checkout-address-empty'),
          )
        else
          _selectionPanel(
            icon: Icons.location_on_rounded,
            title: '${address.label} · ${address.recipientName}',
            subtitle: '${address.addressLine}, ${address.city}',
            detail: [
              address.department,
              if (address.reference != null) address.reference!,
            ].join(' · '),
            changeLabel: 'Cambiar',
            changeKey: const ValueKey('checkout-address-change'),
            onChange: () => _openAddressSelector(book),
            cardKey: const ValueKey('checkout-address-card'),
          ),
      ],
    );
  }

  Widget _buildPaymentSection(List<PaymentMethod> methods) {
    final payment = _resolvePayment(methods);
    final expired = payment != null && _isExpired(payment);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionTitle('Pago'),
        const SizedBox(height: 10),
        if (payment == null)
          _selectionPanel(
            icon: Icons.credit_card_off_outlined,
            title: 'Sin método de pago',
            subtitle: 'Agrega una tarjeta ficticia para continuar.',
            changeLabel: 'Agregar',
            changeKey: const ValueKey('checkout-payment-add'),
            onChange: _addPaymentMethod,
            cardKey: const ValueKey('checkout-payment-empty'),
          )
        else
          _selectionPanel(
            icon: Icons.credit_card_rounded,
            title: '${payment.brand.label} ${payment.maskedNumber}',
            subtitle: 'Vence ${payment.expiryLabel}',
            detail: expired ? 'Método vencido' : null,
            changeLabel: 'Cambiar',
            changeKey: const ValueKey('checkout-payment-change'),
            onChange: () => _openPaymentSelector(methods),
            cardKey: const ValueKey('checkout-payment-card'),
          ),
        if (payment == null) ...[
          const SizedBox(height: 8),
          Text(
            'Agrega un método de pago para confirmar.',
            key: const ValueKey('checkout-payment-required'),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ] else if (expired) ...[
          const SizedBox(height: 8),
          Text(
            'El método de pago está vencido. Elige otro para continuar.',
            key: const ValueKey('checkout-payment-expired'),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildOrderSummary(CartSnapshot snapshot) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionTitle('Resumen'),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            border: Border.all(color: colors.outlineVariant),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final item in snapshot.allItems) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        '${item.product.name} × ${item.quantity}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _formatPrice(item.subtotal),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              const Divider(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Total',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    _formatPrice(snapshot.total),
                    key: const ValueKey('checkout-total'),
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDemoNotice() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Compra de demostración: no se procesa ningún pago real ni se '
        'crea una orden de compra.',
        textAlign: TextAlign.center,
        style: theme.textTheme.bodySmall?.copyWith(
          color: colors.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildConfirmButton({required bool enabled}) {
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        key: const ValueKey('confirm-order-button'),
        onPressed: enabled && !_isSubmitting ? _confirmOrder : null,
        child: _isSubmitting
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text('Procesando…'),
                ],
              )
            : const Text('Confirmar pedido'),
      ),
    );
  }

  Widget _buildConfirmationBar({required bool enabled}) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(16, 12, 16, 14),
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: _buildConfirmButton(enabled: enabled),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartItemsProvider);
    final addresses = ref.watch(addressesProvider);
    final payments = ref.watch(paymentMethodsProvider);
    final cartData = cart.asData?.value;
    final addressBook = addresses.asData?.value;
    final methods = payments.asData?.value;
    final hasError = cart.hasError || addresses.hasError || payments.hasError;
    final isLoading =
        cartData == null || addressBook == null || methods == null;
    final horizontalPadding = MediaQuery.sizeOf(context).width >= 600
        ? 24.0
        : 16.0;

    if (hasError) {
      return Scaffold(
        appBar: AppBar(title: const Text('Finalizar compra')),
        body: _buildError(),
      );
    }

    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Finalizar compra')),
        body: _buildLoading(),
      );
    }

    if (cartData.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Finalizar compra')),
        body: _buildEmptyCheckout(),
      );
    }

    final address = _resolveAddress(addressBook);
    final payment = _resolvePayment(methods);
    final canConfirm =
        address != null &&
        payment != null &&
        !_isExpired(payment) &&
        !cartData.isEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Finalizar compra')),
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              key: const ValueKey('checkout-scroll-view'),
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                20,
                horizontalPadding,
                24,
              ),
              children: [
                _buildAddressSection(addressBook),
                const Divider(height: 32),
                _buildPaymentSection(methods),
                const Divider(height: 32),
                _buildOrderSummary(cartData),
                const SizedBox(height: 20),
                _buildDemoNotice(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildConfirmationBar(enabled: canConfirm),
    );
  }
}
