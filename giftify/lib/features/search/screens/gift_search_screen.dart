import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_router.dart';
import '../../../shared/enums/gift_age_range.dart';
import '../../../shared/enums/gift_format.dart';
import '../../../shared/enums/gift_interest.dart';
import '../../../shared/enums/gift_occasion.dart';
import '../../../shared/enums/gift_recipient.dart';
import '../../../shared/enums/gift_size.dart';
import '../../../shared/models/gift_search_criteria.dart';
import '../models/search_prefill.dart';
import '../providers/search_prefill_provider.dart';

class GiftSearchScreen extends ConsumerStatefulWidget {
  const GiftSearchScreen({super.key});

  @override
  ConsumerState<GiftSearchScreen> createState() => _GiftSearchScreenState();
}

class _GiftSearchScreenState extends ConsumerState<GiftSearchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _budgetController = TextEditingController();
  final _dateController = TextEditingController();

  GiftRecipient? _recipientType;
  GiftOccasion? _occasion;
  GiftAgeRange? _ageRange;
  GiftFormat? _giftFormat;
  GiftSize? _size;
  Set<GiftInterest> _interests = <GiftInterest>{};
  DateTime? _selectedDate;

  bool _isPersonalizable = false;
  bool _isLocal = false;
  bool _fastDelivery = false;
  bool _onlyAvailable = false;
  bool _showOptionalFields = false;

  String? _recipientError;
  String? _occasionError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      final prefill = ref.read(searchPrefillProvider);
      if (prefill != null) {
        _applyPrefill(prefill);
      }
    });
  }

  @override
  void dispose() {
    _budgetController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _applyPrefill(SearchPrefill prefill) {
    if (!mounted) {
      return;
    }

    setState(() {
      _recipientType = prefill.recipientType ?? _recipientType;
      _occasion = prefill.occasion ?? _occasion;
      if (prefill.interests.isNotEmpty) {
        _interests = <GiftInterest>{...prefill.interests};
      }
      _giftFormat = prefill.giftFormat ?? _giftFormat;
      _recipientError = null;
      _occasionError = null;
    });
    ref.read(searchPrefillProvider.notifier).clear();
  }

  void _clearSearch() {
    _formKey.currentState?.reset();
    _budgetController.clear();
    _dateController.clear();
    ref.read(searchPrefillProvider.notifier).clear();

    setState(() {
      _recipientType = null;
      _occasion = null;
      _ageRange = null;
      _giftFormat = null;
      _size = null;
      _interests = <GiftInterest>{};
      _selectedDate = null;
      _isPersonalizable = false;
      _isLocal = false;
      _fastDelivery = false;
      _onlyAvailable = false;
      _showOptionalFields = false;
      _recipientError = null;
      _occasionError = null;
    });
  }

  final RegExp _budgetPattern = RegExp(r'^\d+(?:[.,]\d{1,2})?$');

  double? _parseBudget(String value) {
    final normalized = value.trim();
    if (!_budgetPattern.hasMatch(normalized)) {
      return null;
    }

    return double.tryParse(normalized.replaceAll(',', '.'));
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

  void _submitSearch() {
    final formIsValid = _formKey.currentState?.validate() ?? false;
    final recipient = _recipientType;
    final occasion = _occasion;

    setState(() {
      _recipientError = recipient == null
          ? 'Selecciona para quién es el regalo.'
          : null;
      _occasionError = occasion == null ? 'Selecciona una ocasión.' : null;
    });

    if (!formIsValid || recipient == null || occasion == null) {
      return;
    }

    FocusScope.of(context).unfocus();

    final criteria = GiftSearchCriteria(
      recipientType: recipient,
      occasion: occasion,
      maxBudget: _parseBudget(_budgetController.text)!,
      ageRange: _ageRange,
      interests: Set<GiftInterest>.unmodifiable(_interests),
      giftFormat: _giftFormat,
      size: _size,
      eventDate: _selectedDate,
      isPersonalizable: _isPersonalizable,
      isLocal: _isLocal,
      fastDelivery: _fastDelivery,
      onlyAvailable: _onlyAvailable,
    );

    Navigator.pushNamed(context, AppRoutes.productResults, arguments: criteria);
  }

  void _toggleInterest(GiftInterest interest, bool selected) {
    setState(() {
      if (selected) {
        _interests.add(interest);
      } else {
        _interests.remove(interest);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<SearchPrefill?>(searchPrefillProvider, (previous, next) {
      if (next == null) {
        return;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _applyPrefill(next);
      });
    });

    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Buscar')),
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
                        Text(
                          'Encuentra el regalo ideal',
                          style: theme.textTheme.displaySmall?.copyWith(
                            color: colors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Cuéntanos un poco sobre la persona y la ocasión.',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _SectionLabel(
                          title: '¿Para quién es?',
                          isRequired: true,
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final recipient in GiftRecipient.values)
                              ChoiceChip(
                                key: ValueKey(
                                  'search-recipient-${recipient.name}',
                                ),
                                label: Text(recipient.label),
                                selected: _recipientType == recipient,
                                onSelected: (selected) {
                                  setState(() {
                                    _recipientType = selected
                                        ? recipient
                                        : null;
                                    _recipientError = null;
                                  });
                                },
                              ),
                          ],
                        ),
                        if (_recipientError != null) ...[
                          const SizedBox(height: 6),
                          _InlineError(message: _recipientError!),
                        ],
                        const SizedBox(height: 22),
                        _SectionLabel(
                          title: '¿Cuál es la ocasión?',
                          isRequired: true,
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final occasion in GiftOccasion.values)
                              ChoiceChip(
                                key: ValueKey(
                                  'search-occasion-${occasion.name}',
                                ),
                                label: Text(occasion.label),
                                selected: _occasion == occasion,
                                onSelected: (selected) {
                                  setState(() {
                                    _occasion = selected ? occasion : null;
                                    _occasionError = null;
                                  });
                                },
                              ),
                          ],
                        ),
                        if (_occasionError != null) ...[
                          const SizedBox(height: 6),
                          _InlineError(message: _occasionError!),
                        ],
                        const SizedBox(height: 22),
                        _SectionLabel(
                          title: 'Presupuesto máximo',
                          isRequired: true,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          key: const ValueKey('search-budget-field'),
                          controller: _budgetController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          textInputAction: TextInputAction.done,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          onFieldSubmitted: (_) => _submitSearch(),
                          decoration: const InputDecoration(
                            labelText: 'Presupuesto',
                            hintText: 'Ej. 250 o 250.50',
                            prefixIcon: Icon(Icons.payments_outlined),
                            prefixText: 'Q ',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Ingresa un presupuesto.';
                            }

                            final budget = _parseBudget(value);
                            if (budget == null || !budget.isFinite) {
                              return 'Ingresa un monto válido.';
                            }

                            if (budget <= 0) {
                              return 'El presupuesto debe ser mayor que 0.';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 22),
                        const _SectionLabel(title: '¿Qué le gusta?'),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final interest in GiftInterest.values)
                              FilterChip(
                                key: ValueKey(
                                  'search-interest-${interest.name}',
                                ),
                                label: Text(interest.label),
                                selected: _interests.contains(interest),
                                onSelected: (selected) =>
                                    _toggleInterest(interest, selected),
                              ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        TextButton(
                          key: const ValueKey('search-more-options'),
                          onPressed: () {
                            setState(() {
                              _showOptionalFields = !_showOptionalFields;
                            });
                          },
                          child: Text(
                            _showOptionalFields
                                ? 'Menos opciones'
                                : 'Más opciones',
                            textAlign: TextAlign.center,
                          ),
                        ),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 200),
                          alignment: Alignment.topCenter,
                          child: _showOptionalFields
                              ? _OptionalSearchFields(
                                  dateController: _dateController,
                                  selectedDate: _selectedDate,
                                  onSelectDate: _selectDate,
                                  onClearDate: _clearDate,
                                  ageRange: _ageRange,
                                  onAgeSelected: (value) {
                                    setState(() => _ageRange = value);
                                  },
                                  giftFormat: _giftFormat,
                                  onFormatSelected: (value) {
                                    setState(() => _giftFormat = value);
                                  },
                                  size: _size,
                                  onSizeSelected: (value) {
                                    setState(() => _size = value);
                                  },
                                  isPersonalizable: _isPersonalizable,
                                  onPersonalizableChanged: (value) {
                                    setState(() => _isPersonalizable = value);
                                  },
                                  isLocal: _isLocal,
                                  onLocalChanged: (value) {
                                    setState(() => _isLocal = value);
                                  },
                                  fastDelivery: _fastDelivery,
                                  onFastDeliveryChanged: (value) {
                                    setState(() => _fastDelivery = value);
                                  },
                                  onlyAvailable: _onlyAvailable,
                                  onOnlyAvailableChanged: (value) {
                                    setState(() => _onlyAvailable = value);
                                  },
                                )
                              : const SizedBox(width: double.infinity),
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            key: const ValueKey('search-submit-button'),
                            onPressed: _submitSearch,
                            child: const Text(
                              'Buscar regalos',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            key: const ValueKey('search-clear-button'),
                            onPressed: _clearSearch,
                            child: const Text(
                              'Limpiar',
                              textAlign: TextAlign.center,
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title, this.isRequired = false});

  final String title;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      isRequired ? '$title *' : title,
      style: theme.textTheme.titleMedium?.copyWith(
        color: theme.colorScheme.onSurface,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Theme.of(context).colorScheme.error,
      ),
    );
  }
}

class _OptionalSearchFields extends StatelessWidget {
  const _OptionalSearchFields({
    required this.dateController,
    required this.selectedDate,
    required this.onSelectDate,
    required this.onClearDate,
    required this.ageRange,
    required this.onAgeSelected,
    required this.giftFormat,
    required this.onFormatSelected,
    required this.size,
    required this.onSizeSelected,
    required this.isPersonalizable,
    required this.onPersonalizableChanged,
    required this.isLocal,
    required this.onLocalChanged,
    required this.fastDelivery,
    required this.onFastDeliveryChanged,
    required this.onlyAvailable,
    required this.onOnlyAvailableChanged,
  });

  final TextEditingController dateController;
  final DateTime? selectedDate;
  final VoidCallback onSelectDate;
  final VoidCallback onClearDate;
  final GiftAgeRange? ageRange;
  final ValueChanged<GiftAgeRange?> onAgeSelected;
  final GiftFormat? giftFormat;
  final ValueChanged<GiftFormat?> onFormatSelected;
  final GiftSize? size;
  final ValueChanged<GiftSize?> onSizeSelected;
  final bool isPersonalizable;
  final ValueChanged<bool> onPersonalizableChanged;
  final bool isLocal;
  final ValueChanged<bool> onLocalChanged;
  final bool fastDelivery;
  final ValueChanged<bool> onFastDeliveryChanged;
  final bool onlyAvailable;
  final ValueChanged<bool> onOnlyAvailableChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        Text(
          'Más detalles',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          key: const ValueKey('search-date-field'),
          controller: dateController,
          readOnly: true,
          onTap: onSelectDate,
          decoration: InputDecoration(
            labelText: 'Fecha del regalo',
            hintText: 'DD/MM/AAAA',
            prefixIcon: const Icon(Icons.calendar_today_outlined),
            suffixIcon: selectedDate == null
                ? const Icon(Icons.arrow_drop_down_rounded)
                : IconButton(
                    tooltip: 'Quitar fecha',
                    onPressed: onClearDate,
                    icon: const Icon(Icons.close_rounded),
                  ),
          ),
        ),
        const SizedBox(height: 18),
        const _SectionLabel(title: 'Edad'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final age in GiftAgeRange.values)
              ChoiceChip(
                key: ValueKey('search-age-${age.name}'),
                label: Text(age.label),
                selected: ageRange == age,
                onSelected: (selected) {
                  onAgeSelected(selected ? age : null);
                },
              ),
          ],
        ),
        const SizedBox(height: 18),
        const _SectionLabel(title: 'Formato'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final format in GiftFormat.values)
              ChoiceChip(
                key: ValueKey('search-format-${format.name}'),
                label: Text(format.label),
                selected: giftFormat == format,
                onSelected: (selected) {
                  onFormatSelected(selected ? format : null);
                },
              ),
          ],
        ),
        const SizedBox(height: 18),
        const _SectionLabel(title: 'Tamaño'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final item in GiftSize.values)
              ChoiceChip(
                key: ValueKey('search-size-${item.name}'),
                label: Text(item.label),
                selected: size == item,
                onSelected: (selected) {
                  onSizeSelected(selected ? item : null);
                },
              ),
          ],
        ),
        const SizedBox(height: 18),
        const _SectionLabel(title: 'Preferencias'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilterChip(
              key: const ValueKey('search-personalizable'),
              label: const Text('Personalizable'),
              selected: isPersonalizable,
              onSelected: onPersonalizableChanged,
            ),
            FilterChip(
              key: const ValueKey('search-local'),
              label: const Text('Local'),
              selected: isLocal,
              onSelected: onLocalChanged,
            ),
            FilterChip(
              key: const ValueKey('search-fast-delivery'),
              label: const Text('Entrega rápida'),
              selected: fastDelivery,
              onSelected: onFastDeliveryChanged,
            ),
            FilterChip(
              key: const ValueKey('search-only-available'),
              label: const Text('Solo disponibles'),
              selected: onlyAvailable,
              onSelected: onOnlyAvailableChanged,
            ),
          ],
        ),
      ],
    );
  }
}
