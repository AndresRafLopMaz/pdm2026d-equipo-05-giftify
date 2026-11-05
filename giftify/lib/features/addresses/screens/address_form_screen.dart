import 'package:flutter/material.dart';

import '../../../shared/models/delivery_address.dart';
import '../data/address_book.dart';
import '../data/address_repository.dart';

class AddressFormScreen extends StatefulWidget {
  const AddressFormScreen({
    super.key,
    this.initialAddress,
    required this.onSubmit,
  });

  final DeliveryAddress? initialAddress;
  final Future<void> Function(AddressDraft draft) onSubmit;

  bool get isEditing => initialAddress != null;

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();
  final _recipientController = TextEditingController();
  final _addressLineController = TextEditingController();
  final _cityController = TextEditingController();
  final _departmentController = TextEditingController();
  final _referenceController = TextEditingController();

  late bool _isDefault;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialAddress;
    _labelController.text = initial?.label ?? '';
    _recipientController.text = initial?.recipientName ?? '';
    _addressLineController.text = initial?.addressLine ?? '';
    _cityController.text = initial?.city ?? '';
    _departmentController.text = initial?.department ?? '';
    _referenceController.text = initial?.reference ?? '';
    _isDefault = initial?.isDefault ?? false;
  }

  @override
  void dispose() {
    _labelController.dispose();
    _recipientController.dispose();
    _addressLineController.dispose();
    _cityController.dispose();
    _departmentController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate() || _saving) {
      return;
    }

    setState(() => _saving = true);

    try {
      await widget.onSubmit(
        AddressDraft(
          label: _labelController.text.trim(),
          recipientName: _recipientController.text.trim(),
          addressLine: _addressLineController.text.trim(),
          city: _cityController.text.trim(),
          department: _departmentController.text.trim(),
          reference: _referenceController.text.trim(),
          isDefault: _isDefault,
        ),
      );

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } on AddressException catch (error) {
      if (mounted) {
        _showMessage(error.message);
      }
    } catch (_) {
      if (mounted) {
        _showMessage('No pudimos guardar la dirección. Inténtalo de nuevo.');
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String? _requiredValidator(String? value, String message) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.isEditing;
    final isCurrentDefault = widget.initialAddress?.isDefault ?? false;
    final isArchived = widget.initialAddress?.isArchived ?? false;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final horizontalPadding = MediaQuery.sizeOf(context).width >= 600
        ? 24.0
        : 16.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(editing ? 'Editar dirección' : 'Nueva dirección'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            16,
            horizontalPadding,
            32,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      key: const ValueKey('address-label-field'),
                      controller: _labelController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Etiqueta',
                        hintText: 'Casa, Trabajo, etc.',
                      ),
                      validator: (value) => _requiredValidator(
                        value,
                        'Ingresa un nombre para identificar la dirección.',
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      key: const ValueKey('address-recipient-field'),
                      controller: _recipientController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Destinatario',
                      ),
                      validator: (value) => _requiredValidator(
                        value,
                        'Ingresa el nombre del destinatario.',
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      key: const ValueKey('address-line-field'),
                      controller: _addressLineController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(labelText: 'Dirección'),
                      validator: (value) =>
                          _requiredValidator(value, 'Ingresa la dirección.'),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      key: const ValueKey('address-city-field'),
                      controller: _cityController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(labelText: 'Ciudad'),
                      validator: (value) =>
                          _requiredValidator(value, 'Ingresa la ciudad.'),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      key: const ValueKey('address-department-field'),
                      controller: _departmentController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Departamento',
                      ),
                      validator: (value) =>
                          _requiredValidator(value, 'Ingresa el departamento.'),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      key: const ValueKey('address-reference-field'),
                      controller: _referenceController,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        labelText: 'Referencia (opcional)',
                      ),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      key: const ValueKey('address-default-switch'),
                      contentPadding: EdgeInsets.zero,
                      value: _isDefault,
                      onChanged: isCurrentDefault || isArchived
                          ? null
                          : (value) => setState(() => _isDefault = value),
                      title: const Text('Usar como dirección principal'),
                      subtitle: isCurrentDefault
                          ? const Text('Esta es la dirección principal.')
                          : isArchived
                          ? const Text('Restaura la dirección para usarla.')
                          : null,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      key: const ValueKey('address-submit-button'),
                      onPressed: _saving ? null : _submit,
                      child: _saving
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colors.primary,
                              ),
                            )
                          : Text(
                              editing ? 'Guardar cambios' : 'Guardar dirección',
                            ),
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
