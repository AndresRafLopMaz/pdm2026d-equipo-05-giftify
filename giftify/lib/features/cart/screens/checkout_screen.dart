import 'package:flutter/material.dart';

import '../../../shared/enums/payment_method_type.dart';
import '../../../shared/models/cart_item.dart';
import '../../../shared/models/delivery_address.dart';

/// Pantalla 7 — Check-out.
///
/// Responsable principal: Catherine.
///
/// Recibe los elementos confirmados en el carrito.
/// La dirección y el método de pago se manejarán dentro de este módulo.
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

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: const OutlineInputBorder(),
    );
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

  Widget _buildOrderSummary(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen del pedido',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            for (var index = 0; index < widget.items.length; index++) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      '${widget.items[index].product.name} '
                      '× ${widget.items[index].quantity}',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _formatPrice(widget.items[index].subtotal),
                    key: ValueKey('checkout-subtotal-$index'),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              if (index < widget.items.length - 1) const Divider(height: 24),
            ],
            const Divider(height: 28),
            Wrap(
              spacing: 16,
              runSpacing: 4,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'Total',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  _formatPrice(_total),
                  key: const ValueKey('checkout-total'),
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressForm(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dirección de entrega',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const ValueKey('recipient-field'),
              controller: _recipientController,
              enabled: !_isProcessing,
              textInputAction: TextInputAction.next,
              decoration: _inputDecoration(
                'Nombre del receptor',
                Icons.person_outline_rounded,
              ),
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const ValueKey('address-field'),
              controller: _addressController,
              enabled: !_isProcessing,
              textInputAction: TextInputAction.next,
              decoration: _inputDecoration(
                'Dirección',
                Icons.location_on_outlined,
              ),
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const ValueKey('city-field'),
              controller: _cityController,
              enabled: !_isProcessing,
              textInputAction: TextInputAction.next,
              decoration: _inputDecoration('Ciudad', Icons.location_city),
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const ValueKey('department-field'),
              controller: _departmentController,
              enabled: !_isProcessing,
              textInputAction: TextInputAction.next,
              decoration: _inputDecoration('Departamento', Icons.map_outlined),
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const ValueKey('reference-field'),
              controller: _referenceController,
              enabled: !_isProcessing,
              textInputAction: TextInputAction.done,
              maxLines: 2,
              decoration: _inputDecoration(
                'Referencia (opcional)',
                Icons.signpost_outlined,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethods(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Método de pago',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  key: const ValueKey('payment-card'),
                  label: const Text('Tarjeta'),
                  avatar: const Icon(Icons.credit_card_rounded),
                  selected: _selectedPaymentMethod == PaymentMethodType.card,
                  onSelected: _isProcessing
                      ? null
                      : (_) => _selectPaymentMethod(PaymentMethodType.card),
                ),
                ChoiceChip(
                  key: const ValueKey('payment-cash'),
                  label: const Text('Contra entrega'),
                  avatar: const Icon(Icons.payments_outlined),
                  selected:
                      _selectedPaymentMethod ==
                      PaymentMethodType.cashOnDelivery,
                  onSelected: _isProcessing
                      ? null
                      : (_) => _selectPaymentMethod(
                          PaymentMethodType.cashOnDelivery,
                        ),
                ),
              ],
            ),
            if (_showPaymentError) ...[
              const SizedBox(height: 8),
              Text(
                'Selecciona un método de pago.',
                style: textTheme.bodySmall?.copyWith(color: colors.error),
              ),
            ],
            if (_selectedPaymentMethod == PaymentMethodType.card) ...[
              const SizedBox(height: 12),
              const Text(
                'Tarjeta •••• 4242 (simulación, no se procesarán datos reales).',
                key: ValueKey('card-simulation-message'),
              ),
            ],
            if (_selectedPaymentMethod == PaymentMethodType.cashOnDelivery) ...[
              const SizedBox(height: 12),
              const Text(
                'Pagarás al recibir el pedido.',
                key: ValueKey('cash-on-delivery-message'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        key: const ValueKey('confirm-order-button'),
        onPressed: widget.items.isEmpty || _isProcessing ? null : _confirmOrder,
        child: _isProcessing
            ? const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 10),
                  Text('Procesando...'),
                ],
              )
            : const Text('Confirmar pedido'),
      ),
    );
  }

  Widget _buildEmptyCheckout(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.remove_shopping_cart_outlined,
                      size: 72,
                      color: colors.primary,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'No hay productos para procesar.',
                      textAlign: TextAlign.center,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildConfirmButton(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Check-out')),
      body: widget.items.isEmpty
          ? _buildEmptyCheckout(context)
          : SafeArea(
              child: Form(
                key: _formKey,
                child: ListView(
                  key: const ValueKey('checkout-scroll-view'),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    _buildOrderSummary(context),
                    const SizedBox(height: 12),
                    _buildAddressForm(context),
                    const SizedBox(height: 12),
                    _buildPaymentMethods(context),
                    const SizedBox(height: 20),
                    _buildConfirmButton(),
                  ],
                ),
              ),
            ),
    );
  }
}
