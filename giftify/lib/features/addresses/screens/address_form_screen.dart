import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
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

    return Scaffold(
      appBar: AppBar(
        title: Text(editing ? 'Editar dirección' : 'Nueva dirección'),
        backgroundColor: fondoPrincipal,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
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
                    border: OutlineInputBorder(),
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
                    border: OutlineInputBorder(),
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
                  decoration: const InputDecoration(
                    labelText: 'Dirección',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      _requiredValidator(value, 'Ingresa la dirección.'),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  key: const ValueKey('address-city-field'),
                  controller: _cityController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Ciudad',
                    border: OutlineInputBorder(),
                  ),
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
                    border: OutlineInputBorder(),
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
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  key: const ValueKey('address-default-switch'),
                  contentPadding: EdgeInsets.zero,
                  value: _isDefault,
                  onChanged: isCurrentDefault
                      ? null
                      : (value) => setState(() => _isDefault = value),
                  title: const Text('Usar como dirección principal'),
                  subtitle: isCurrentDefault
                      ? const Text('Esta dirección está en uso.')
                      : null,
                ),
                const SizedBox(height: 18),
                FilledButton(
                  key: const ValueKey('address-submit-button'),
                  onPressed: _saving ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: verdePrincipal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(editing ? 'Guardar cambios' : 'Crear'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
