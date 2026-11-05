import 'package:flutter/material.dart';

import '../../../shared/enums/payment_method_type.dart';
import '../../../shared/models/cart_item.dart';
import '../../../shared/models/delivery_address.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key, this.items = const []});

  final List<CartItem> items;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _recipientController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _departmentController = TextEditingController();
  final _referenceController = TextEditingController();

  PaymentMethodType? _selectedPaymentMethod;
  bool _showPaymentError = false;
  bool _isProcessing = false;

  double get _total =>
      widget.items.fold(0, (total, item) => total + item.subtotal);

  @override
  void dispose() {
    _recipientController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _departmentController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  String _formatPrice(double price) => 'Q ${price.toStringAsFixed(2)}';

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es obligatorio.';
    }

    return null;
  }

  void _selectPaymentMethod(PaymentMethodType method) {
    setState(() {
      _selectedPaymentMethod = method;
      _showPaymentError = false;
    });
  }

  Future<void> _confirmOrder() async {
    if (_isProcessing || widget.items.isEmpty) {
      return;
    }

    final isAddressValid = _formKey.currentState!.validate();
    final paymentMethod = _selectedPaymentMethod;

    setState(() {
      _showPaymentError = paymentMethod == null;
    });

    if (!isAddressValid || paymentMethod == null) {
      return;
    }

    FocusScope.of(context).unfocus();

    final reference = _referenceController.text.trim();
    final deliveryAddress = DeliveryAddress(
      id: 'checkout-delivery-address',
      label: 'Entrega',
      recipientName: _recipientController.text.trim(),
      addressLine: _addressController.text.trim(),
      city: _cityController.text.trim(),
      department: _departmentController.text.trim(),
      reference: reference.isEmpty ? null : reference,
    );

    setState(() {
      _isProcessing = true;
    });

    await Future<void>.delayed(const Duration(milliseconds: 300));

    if (!mounted) {
      return;
    }

    setState(() {
      _isProcessing = false;
    });

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final paymentDescription = paymentMethod == PaymentMethodType.card
            ? 'Tarjeta simulada •••• 4242'
            : 'Pago contra entrega';

        return AlertDialog(
          title: const Text('Pedido confirmado'),
          content: Text(
            'Confirmación simulada para ${deliveryAddress.recipientName}.\n\n'
            'Entrega en ${deliveryAddress.addressLine}, '
            '${deliveryAddress.city}, ${deliveryAddress.department}.\n\n'
            '$paymentDescription.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Entendido'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAddressForm(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Entrega',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          key: const ValueKey('recipient-field'),
          controller: _recipientController,
          enabled: !_isProcessing,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            labelText: 'Receptor',
            prefixIcon: Icon(Icons.person_outline_rounded),
          ),
          validator: _requiredValidator,
        ),
        const SizedBox(height: 12),
        TextFormField(
          key: const ValueKey('address-field'),
          controller: _addressController,
          enabled: !_isProcessing,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            labelText: 'Dirección',
            prefixIcon: Icon(Icons.location_on_outlined),
          ),
          validator: _requiredValidator,
        ),
        const SizedBox(height: 12),
        TextFormField(
          key: const ValueKey('city-field'),
          controller: _cityController,
          enabled: !_isProcessing,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            labelText: 'Ciudad',
            prefixIcon: Icon(Icons.location_city),
          ),
          validator: _requiredValidator,
        ),
        const SizedBox(height: 12),
        TextFormField(
          key: const ValueKey('department-field'),
          controller: _departmentController,
          enabled: !_isProcessing,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            labelText: 'Departamento',
            prefixIcon: Icon(Icons.map_outlined),
          ),
          validator: _requiredValidator,
        ),
        const SizedBox(height: 12),
        TextFormField(
          key: const ValueKey('reference-field'),
          controller: _referenceController,
          enabled: !_isProcessing,
          textInputAction: TextInputAction.done,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Referencia (opcional)',
            prefixIcon: Icon(Icons.signpost_outlined),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethods(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Pago',
          style: theme.textTheme.titleLarge?.copyWith(color: colors.onSurface),
        ),
        const SizedBox(height: 8),
        RadioGroup<PaymentMethodType>(
          groupValue: _selectedPaymentMethod,
          onChanged: (value) {
            if (value != null && !_isProcessing) {
              _selectPaymentMethod(value);
            }
          },
          child: Column(
            children: [
              RadioListTile<PaymentMethodType>(
                key: const ValueKey('payment-card'),
                value: PaymentMethodType.card,
                enabled: !_isProcessing,
                contentPadding: EdgeInsets.zero,
                secondary: const Icon(Icons.credit_card_rounded),
                title: const Text('Tarjeta'),
                subtitle: const Text('Simulación segura'),
              ),
              RadioListTile<PaymentMethodType>(
                key: const ValueKey('payment-cash'),
                value: PaymentMethodType.cashOnDelivery,
                enabled: !_isProcessing,
                contentPadding: EdgeInsets.zero,
                secondary: const Icon(Icons.payments_outlined),
                title: const Text('Pago contra entrega'),
                subtitle: const Text('Paga cuando recibas el pedido'),
              ),
            ],
          ),
        ),
        if (_showPaymentError) ...[
          const SizedBox(height: 4),
          Text(
            'Selecciona un método de pago.',
            style: theme.textTheme.bodyMedium?.copyWith(color: colors.error),
          ),
        ],
      ],
    );
  }

  Widget _buildOrderSummary(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final count = widget.items.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Resumen',
          style: theme.textTheme.titleLarge?.copyWith(color: colors.onSurface),
        ),
        const SizedBox(height: 8),
        Text(
          '$count ${count == 1 ? 'producto' : 'productos'}',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
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
              _formatPrice(_total),
              key: const ValueKey('checkout-total'),
              style: theme.textTheme.titleLarge?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildConfirmButton() {
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        key: const ValueKey('confirm-order-button'),
        onPressed: widget.items.isEmpty || _isProcessing ? null : _confirmOrder,
        child: _isProcessing
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
                  const Text('Procesando...'),
                ],
              )
            : const Text('Confirmar pedido'),
      ),
    );
  }

  Widget _buildConfirmationBar(BuildContext context) {
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
            child: _buildConfirmButton(),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCheckout(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: Padding(
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
              'No hay productos para procesar.',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = MediaQuery.sizeOf(context).width >= 600
        ? 24.0
        : 16.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Finalizar compra')),
      body: widget.items.isEmpty
          ? _buildEmptyCheckout(context)
          : SafeArea(
              bottom: false,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      key: const ValueKey('checkout-scroll-view'),
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        20,
                        horizontalPadding,
                        24,
                      ),
                      children: [
                        _buildAddressForm(context),
                        const Divider(height: 32),
                        _buildPaymentMethods(context),
                        const Divider(height: 32),
                        _buildOrderSummary(context),
                      ],
                    ),
                  ),
                ),
              ),
            ),
      bottomNavigationBar: _buildConfirmationBar(context),
    );
  }
}
