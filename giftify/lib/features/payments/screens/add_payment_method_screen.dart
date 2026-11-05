import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/enums/payment_brand.dart';
import '../data/payment_method_errors.dart';
import '../providers/payment_methods_provider.dart';
import '../widgets/payment_demo_notice.dart';

class AddPaymentMethodScreen extends ConsumerStatefulWidget {
  const AddPaymentMethodScreen({super.key, this.now});

  final DateTime? now;

  @override
  ConsumerState<AddPaymentMethodScreen> createState() =>
      _AddPaymentMethodScreenState();
}

class _AddPaymentMethodScreenState
    extends ConsumerState<AddPaymentMethodScreen> {
  final _formKey = GlobalKey<FormState>();
  final _holderController = TextEditingController();
  final _last4Controller = TextEditingController();

  late final DateTime Function() _clock;
  late int _selectedMonth;
  late int _selectedYear;
  PaymentBrand? _selectedBrand;
  bool _useAsDefault = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  static final RegExp _last4Pattern = RegExp(r'^[0-9]{4}$');

  @override
  void initState() {
    super.initState();
    final fixedNow = widget.now;
    _clock = fixedNow == null ? DateTime.now : () => fixedNow;
    final current = _clock();
    _selectedMonth = current.month;
    _selectedYear = current.year;
  }

  @override
  void dispose() {
    _holderController.dispose();
    _last4Controller.dispose();
    super.dispose();
  }

  String? _validateHolder(String? value) {
    final holder = value?.trim() ?? '';
    if (holder.isEmpty) {
      return 'Ingresa el nombre del titular.';
    }
    if (holder.length > 80) {
      return 'El nombre del titular es demasiado largo.';
    }
    return null;
  }

  String? _validateBrand(PaymentBrand? value) {
    if (value == null) {
      return 'Selecciona una marca.';
    }
    return null;
  }

  String? _validateLast4(String? value) {
    final last4 = value?.trim() ?? '';
    if (!_last4Pattern.hasMatch(last4)) {
      return 'Ingresa exactamente 4 dígitos.';
    }
    return null;
  }

  String? _validateMonth(int? value) {
    if (value == null) {
      return 'Selecciona el mes.';
    }
    if (_isExpired(value, _selectedYear)) {
      return 'La fecha no puede estar en el pasado.';
    }
    return null;
  }

  String? _validateYear(int? value) {
    if (value == null) {
      return 'Selecciona el año.';
    }
    if (_isExpired(_selectedMonth, value)) {
      return 'La fecha no puede estar en el pasado.';
    }
    return null;
  }

  bool _isExpired(int month, int year) {
    final now = _clock();
    return year < now.year || (year == now.year && month < now.month);
  }

  Future<void> _submit() async {
    if (_isSubmitting) {
      return;
    }

    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await ref
          .read(paymentMethodsProvider.notifier)
          .add(
            holderName: _holderController.text,
            brand: _selectedBrand!,
            last4: _last4Controller.text,
            expiryMonth: _selectedMonth,
            expiryYear: _selectedYear,
            isDefault: _useAsDefault,
          );

      if (!mounted) {
        return;
      }
      Navigator.pop(context, true);
    } on InvalidPaymentMethodException catch (error) {
      _showError(error.message);
    } on PaymentMethodStorageException {
      _showError('No pudimos guardar el método de pago.');
    } catch (_) {
      _showError('No pudimos guardar el método de pago.');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showError(String message) {
    if (!mounted) {
      return;
    }
    setState(() {
      _errorMessage = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final horizontalPadding = MediaQuery.sizeOf(context).width >= 600
        ? 24.0
        : 16.0;
    final currentYear = _clock().year;
    final years = [
      for (var year = currentYear; year <= currentYear + 20; year++) year,
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Agregar método de pago')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            20,
            horizontalPadding,
            32,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const PaymentDemoNotice(),
                    const SizedBox(height: 20),
                    TextFormField(
                      key: const ValueKey('payment-holder'),
                      controller: _holderController,
                      enabled: !_isSubmitting,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      validator: _validateHolder,
                      decoration: const InputDecoration(
                        labelText: 'Titular',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<PaymentBrand>(
                      key: const ValueKey('payment-brand'),
                      initialValue: _selectedBrand,
                      isExpanded: true,
                      validator: _validateBrand,
                      decoration: const InputDecoration(
                        labelText: 'Marca',
                        prefixIcon: Icon(Icons.credit_card_rounded),
                      ),
                      items: [
                        for (final brand in PaymentBrand.values)
                          DropdownMenuItem(
                            value: brand,
                            child: Text(brand.label),
                          ),
                      ],
                      onChanged: _isSubmitting
                          ? null
                          : (value) {
                              setState(() {
                                _selectedBrand = value;
                              });
                            },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      key: const ValueKey('payment-last4'),
                      controller: _last4Controller,
                      enabled: !_isSubmitting,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      validator: _validateLast4,
                      decoration: const InputDecoration(
                        labelText: 'Últimos 4 dígitos',
                        prefixIcon: Icon(Icons.numbers_rounded),
                      ),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<int>(
                      key: const ValueKey('payment-month'),
                      initialValue: _selectedMonth,
                      isExpanded: true,
                      validator: _validateMonth,
                      decoration: const InputDecoration(
                        labelText: 'Mes de vencimiento',
                        prefixIcon: Icon(Icons.calendar_month_outlined),
                      ),
                      items: [
                        for (var month = 1; month <= 12; month++)
                          DropdownMenuItem(
                            value: month,
                            child: Text(month.toString().padLeft(2, '0')),
                          ),
                      ],
                      onChanged: _isSubmitting
                          ? null
                          : (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedMonth = value;
                                });
                              }
                            },
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<int>(
                      key: const ValueKey('payment-year'),
                      initialValue: _selectedYear,
                      isExpanded: true,
                      validator: _validateYear,
                      decoration: const InputDecoration(
                        labelText: 'Año de vencimiento',
                        prefixIcon: Icon(Icons.event_outlined),
                      ),
                      items: [
                        for (final year in years)
                          DropdownMenuItem(
                            value: year,
                            child: Text(year.toString()),
                          ),
                      ],
                      onChanged: _isSubmitting
                          ? null
                          : (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedYear = value;
                                });
                              }
                            },
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: SwitchListTile(
                        key: const ValueKey('payment-default'),
                        value: _useAsDefault,
                        onChanged: _isSubmitting
                            ? null
                            : (value) {
                                setState(() {
                                  _useAsDefault = value;
                                });
                              },
                        title: const Text('Usar como predeterminado'),
                      ),
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _errorMessage!,
                        key: const ValueKey('payment-form-error'),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    FilledButton(
                      key: const ValueKey('payment-submit'),
                      onPressed: _isSubmitting ? null : _submit,
                      child: _isSubmitting
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colors.primary,
                              ),
                            )
                          : const Text('Guardar método de pago'),
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
