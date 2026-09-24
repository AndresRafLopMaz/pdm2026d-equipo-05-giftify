import 'package:flutter/material.dart';

import '../../../app/app_router.dart';
import '../../../core/theme/app_theme.dart';
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
    'Accesorios',
    'Bienestar',
    'Detalles',
    'Tecnología',
    'Experiencias',
  ];

  static const _sizes = ['Pequeño', 'Mediano', 'Grande'];

  String? _selectedOccasion;
  String? _selectedRecipient;
  String? _selectedGiftType;
  String? _selectedSize;
  DateTime? _selectedDate;

  @override
  void dispose() {
    _dateController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    String? hint,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: verdeOscuro),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE1E6E3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE1E6E3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: verdePrincipal, width: 2),
      ),
    );
  }

  Widget _responsiveRow({
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
            behavior: SnackBarBehavior.floating,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personalizar búsqueda'),
        backgroundColor: fondoPrincipal,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [verdePrincipal, verdeOscuro],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.tune_rounded,
                                color: Colors.white,
                                size: 34,
                              ),
                              SizedBox(height: 14),
                              Text(
                                'Cuéntanos qué estás buscando',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Usaremos estos datos para encontrar opciones que se adapten a tu regalo.',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 26),
                        const Text(
                          'Datos principales',
                          style: TextStyle(
                            color: textoPrincipal,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Los campos marcados con * son obligatorios.',
                          style: TextStyle(color: textoSecundario),
                        ),
                        const SizedBox(height: 18),
                        _responsiveRow(
                          availableWidth: constraints.maxWidth,
                          first: DropdownButtonFormField<String>(
                            initialValue: _selectedOccasion,
                            isExpanded: true,
                            decoration: _inputDecoration(
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
                            initialValue: _selectedRecipient,
                            isExpanded: true,
                            decoration: _inputDecoration(
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
                        _responsiveRow(
                          availableWidth: constraints.maxWidth,
                          first: TextFormField(
                            controller: _dateController,
                            readOnly: true,
                            onTap: _selectDate,
                            decoration: _inputDecoration(
                              label: 'Fecha (opcional)',
                              hint: 'DD/MM/AAAA',
                              icon: Icons.calendar_today_outlined,
                              suffixIcon: _selectedDate == null
                                  ? const Icon(Icons.arrow_drop_down_rounded)
                                  : IconButton(
                                      tooltip: 'Quitar fecha',
                                      onPressed: _clearDate,
                                      icon: const Icon(Icons.close_rounded),
                                    ),
                            ),
                          ),
                          second: DropdownButtonFormField<String>(
                            initialValue: _selectedGiftType,
                            isExpanded: true,
                            decoration: _inputDecoration(
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
                              setState(() => _selectedGiftType = value);
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        _responsiveRow(
                          availableWidth: constraints.maxWidth,
                          first: DropdownButtonFormField<String>(
                            initialValue: _selectedSize,
                            isExpanded: true,
                            decoration: _inputDecoration(
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
                          second: TextFormField(
                            controller: _budgetController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _submitSearch(),
                            decoration: _inputDecoration(
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
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _submitSearch,
                            style: FilledButton.styleFrom(
                              backgroundColor: rosaPrincipal,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 17),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(17),
                              ),
                            ),
                            icon: const Icon(Icons.search_rounded),
                            label: const Text(
                              'Buscar regalos',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
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
