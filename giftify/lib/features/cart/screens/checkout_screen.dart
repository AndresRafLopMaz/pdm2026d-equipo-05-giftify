import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
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
      prefixIcon: Icon(icon, color: rosaPrincipal),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE4E1E3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: rosaPrincipal, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }

  RoundedRectangleBorder _cardShape(ColorScheme colors) {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
      side: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.7)),
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
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: colors.surface,
      shape: _cardShape(colors),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.receipt_long_outlined, color: rosaPrincipal),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Resumen del pedido',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
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
                    color: rosaPrincipal,
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
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: colors.surface,
      shape: _cardShape(colors),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: rosaClaro,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.location_on_outlined,
                    color: rosaPrincipal,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Dirección de entrega',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
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

  Widget _buildPaymentOption({
    required PaymentMethodType method,
    required String title,
    required String subtitle,
    required IconData icon,
    required Key key,
  }) {
    final isSelected = _selectedPaymentMethod == method;
    final colors = Theme.of(context).colorScheme;

    return Semantics(
      key: key,
      button: true,
      selected: isSelected,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _isProcessing ? null : () => _selectPaymentMethod(method),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isSelected ? rosaClaro : colors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? rosaPrincipal : colors.outlineVariant,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : rosaClaro,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: rosaPrincipal),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(color: colors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  isSelected
                      ? Icons.check_circle_rounded
                      : Icons.circle_outlined,
                  color: isSelected ? rosaPrincipal : colors.outlineVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethods(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.wallet_outlined, color: rosaPrincipal),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Método de pago',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildPaymentOption(
          key: const ValueKey('payment-card'),
          method: PaymentMethodType.card,
          title: 'Tarjeta',
          subtitle: 'Simulación segura',
          icon: Icons.credit_card_rounded,
        ),
        const SizedBox(height: 10),
        _buildPaymentOption(
          key: const ValueKey('payment-cash'),
          method: PaymentMethodType.cashOnDelivery,
          title: 'Pago contra entrega',
          subtitle: 'Paga cuando recibas el pedido',
          icon: Icons.payments_outlined,
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
    );
  }

  Widget _buildConfirmButton() {
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        key: const ValueKey('confirm-order-button'),
        onPressed: widget.items.isEmpty || _isProcessing ? null : _confirmOrder,
        style: FilledButton.styleFrom(
          backgroundColor: rosaPrincipal,
          foregroundColor: Colors.white,
          disabledBackgroundColor: colors.surfaceContainerHighest,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isProcessing
            ? const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text('Procesando...'),
                ],
              )
            : const Text('Confirmar pedido'),
      ),
    );
  }

  Widget _buildConfirmationBar(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.surface,
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(16, 12, 16, 14),
        child: _buildConfirmButton(),
      ),
    );
  }

  Widget _buildEmptyCheckout(BuildContext context) {
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
                      color: rosaPrincipal,
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
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check-out'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
            height: 1,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
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
                    _buildAddressForm(context),
                    const SizedBox(height: 20),
                    _buildPaymentMethods(context),
                    const SizedBox(height: 20),
                    _buildOrderSummary(context),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: _buildConfirmationBar(context),
    );
  }
}
