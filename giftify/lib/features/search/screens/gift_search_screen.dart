import 'package:flutter/material.dart';

import '../../../app/app_router.dart';
import '../../../shared/models/gift_search_criteria.dart';

class GiftSearchScreen extends StatefulWidget {
  const GiftSearchScreen({super.key});

  @override
  State<GiftSearchScreen> createState() => _GiftSearchScreenState();
}

class _GiftSearchScreenState extends State<GiftSearchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _budgetController = TextEditingController();

  static const _occasions = [
    'Cumpleaños',
    'Aniversario',
    'Graduación',
    'Amistad',
    'Otra ocasión',
  ];

  static const _recipients = [
    'Pareja',
    'Familiar',
    'Amigo/a',
    'Compañero/a',
    'Otra persona',
  ];

  static const _giftTypes = [
    'Joyería',
    'Alimentos',
    'Accesorios',
    'Artesanías',
    'Personalizados',
  ];

  static const _sizes = ['Pequeño', 'Mediano', 'Grande'];

  String? _selectedOccasion;
  String? _selectedRecipient;
  String? _selectedGiftType;
  String? _selectedSize;
  DateTime? _selectedDate;
  bool _showOptionalFields = false;

  @override
  void dispose() {
    _dateController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final selected = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? today,
      firstDate: today,
      lastDate: DateTime(today.year + 10, 12, 31),
      helpText: 'Selecciona la fecha del regalo',
      cancelText: 'Cancelar',
      confirmText: 'Seleccionar',
    );

    if (selected == null || !mounted) {
      return;
    }

    setState(() {
      _selectedDate = selected;
      _dateController.text =
          '${selected.day.toString().padLeft(2, '0')}/'
          '${selected.month.toString().padLeft(2, '0')}/'
          '${selected.year}';
    });
  }

  void _clearDate() {
    setState(() {
      _selectedDate = null;
      _dateController.clear();
    });
  }

  double? _parseBudget(String value) {
    return double.tryParse(value.trim().replaceAll(',', '.'));
  }

  void _submitSearch() {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Revisa los campos obligatorios antes de continuar.'),
          ),
        );
      return;
    }

    final criteria = GiftSearchCriteria(
      occasion: _selectedOccasion!,
      recipient: _selectedRecipient!,
      maxBudget: _parseBudget(_budgetController.text)!,
      eventDate: _selectedDate,
      giftType: _selectedGiftType,
      size: _selectedSize,
    );

    Navigator.pushNamed(context, AppRoutes.productResults, arguments: criteria);
  }

  Widget _twoColumns({
    required double availableWidth,
    required Widget first,
    required Widget second,
  }) {
    if (availableWidth < 620) {
      return Column(children: [first, const SizedBox(height: 16), second]);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: first),
        const SizedBox(width: 16),
        Expanded(child: second),
      ],
    );
  }

  InputDecoration _decoration({
    required String label,
    required IconData icon,
    String? hint,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      suffixIcon: suffixIcon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Personalizar búsqueda')),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth >= 600 ? 24.0 : 16.0;

            return SingleChildScrollView(
              key: const PageStorageKey('search-scroll'),
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                16,
                horizontalPadding,
                32,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _twoColumns(
                          availableWidth: constraints.maxWidth,
                          first: DropdownButtonFormField<String>(
                            key: const ValueKey('search-occasion-field'),
                            initialValue: _selectedOccasion,
                            isExpanded: true,
                            decoration: _decoration(
                              label: 'Ocasión *',
                              icon: Icons.celebration_outlined,
                            ),
                            items: _occasions
                                .map(
                                  (occasion) => DropdownMenuItem(
                                    value: occasion,
                                    child: Text(occasion),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() => _selectedOccasion = value);
                            },
                            validator: (value) => value == null
                                ? 'Selecciona una ocasión.'
                                : null,
                          ),
                          second: DropdownButtonFormField<String>(
                            key: const ValueKey('search-recipient-field'),
                            initialValue: _selectedRecipient,
                            isExpanded: true,
                            decoration: _decoration(
                              label: 'Destinatario *',
                              icon: Icons.person_outline_rounded,
                            ),
                            items: _recipients
                                .map(
                                  (recipient) => DropdownMenuItem(
                                    value: recipient,
                                    child: Text(recipient),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() => _selectedRecipient = value);
                            },
                            validator: (value) => value == null
                                ? 'Selecciona un destinatario.'
                                : null,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          key: const ValueKey('search-budget-field'),
                          controller: _budgetController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submitSearch(),
                          decoration: _decoration(
                            label: 'Presupuesto máximo *',
                            hint: 'Ej. 250.00',
                            icon: Icons.payments_outlined,
                          ).copyWith(prefixText: 'Q '),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Ingresa un presupuesto.';
                            }

                            final budget = _parseBudget(value);
                            if (budget == null) {
                              return 'Ingresa un monto válido.';
                            }

                            if (budget <= 0) {
                              return 'El presupuesto debe ser mayor que 0.';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            key: const ValueKey('search-more-options'),
                            onPressed: () {
                              setState(() {
                                _showOptionalFields = !_showOptionalFields;
                              });
                            },
                            icon: Icon(
                              _showOptionalFields
                                  ? Icons.expand_less_rounded
                                  : Icons.expand_more_rounded,
                            ),
                            label: Text(
                              _showOptionalFields
                                  ? 'Menos opciones'
                                  : 'Más opciones',
                            ),
                          ),
                        ),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 200),
                          alignment: Alignment.topCenter,
                          child: _showOptionalFields
                              ? Column(
                                  children: [
                                    _twoColumns(
                                      availableWidth: constraints.maxWidth,
                                      first: TextFormField(
                                        key: const ValueKey(
                                          'search-date-field',
                                        ),
                                        controller: _dateController,
                                        readOnly: true,
                                        onTap: _selectDate,
                                        decoration: _decoration(
                                          label: 'Fecha (opcional)',
                                          hint: 'DD/MM/AAAA',
                                          icon: Icons.calendar_today_outlined,
                                          suffixIcon: _selectedDate == null
                                              ? const Icon(
                                                  Icons.arrow_drop_down_rounded,
                                                )
                                              : IconButton(
                                                  tooltip: 'Quitar fecha',
                                                  onPressed: _clearDate,
                                                  icon: const Icon(
                                                    Icons.close_rounded,
                                                  ),
                                                ),
                                        ),
                                      ),
                                      second: DropdownButtonFormField<String>(
                                        key: const ValueKey(
                                          'search-gift-type-field',
                                        ),
                                        initialValue: _selectedGiftType,
                                        isExpanded: true,
                                        decoration: _decoration(
                                          label: 'Tipo de regalo (opcional)',
                                          icon: Icons.card_giftcard_rounded,
                                        ),
                                        items: _giftTypes
                                            .map(
                                              (giftType) => DropdownMenuItem(
                                                value: giftType,
                                                child: Text(giftType),
                                              ),
                                            )
                                            .toList(),
                                        onChanged: (value) {
                                          setState(
                                            () => _selectedGiftType = value,
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    DropdownButtonFormField<String>(
                                      key: const ValueKey('search-size-field'),
                                      initialValue: _selectedSize,
                                      isExpanded: true,
                                      decoration: _decoration(
                                        label: 'Tamaño (opcional)',
                                        icon: Icons.straighten_rounded,
                                      ),
                                      items: _sizes
                                          .map(
                                            (size) => DropdownMenuItem(
                                              value: size,
                                              child: Text(size),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (value) {
                                        setState(() => _selectedSize = value);
                                      },
                                    ),
                                  ],
                                )
                              : const SizedBox(width: double.infinity),
                        ),
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          key: const ValueKey('search-submit-button'),
                          onPressed: _submitSearch,
                          icon: const Icon(Icons.search_rounded),
                          label: const Text('Buscar regalos'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
