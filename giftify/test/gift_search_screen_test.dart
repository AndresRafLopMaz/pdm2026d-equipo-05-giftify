import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:giftify/app/app_router.dart';
import 'package:giftify/core/theme/app_theme.dart';
import 'package:giftify/features/search/models/search_prefill.dart';
import 'package:giftify/features/search/providers/search_prefill_provider.dart';
import 'package:giftify/features/search/screens/gift_search_screen.dart';
import 'package:giftify/shared/enums/gift_age_range.dart';
import 'package:giftify/shared/enums/gift_format.dart';
import 'package:giftify/shared/enums/gift_interest.dart';
import 'package:giftify/shared/enums/gift_occasion.dart';
import 'package:giftify/shared/enums/gift_recipient.dart';
import 'package:giftify/shared/enums/gift_size.dart';
import 'package:giftify/shared/models/gift_search_criteria.dart';

Future<ProviderContainer> _pumpSearch(
  WidgetTester tester, {
  SearchPrefill? prefill,
  ValueChanged<RouteSettings>? onResults,
}) async {
  final container = ProviderContainer();
  addTearDown(container.dispose);

  if (prefill != null) {
    container.read(searchPrefillProvider.notifier).set(prefill);
  }

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: appTheme,
        home: const GiftSearchScreen(),
        onGenerateRoute: (settings) {
          if (settings.name == AppRoutes.productResults) {
            onResults?.call(settings);
          }

          return MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => const Scaffold(body: Text('Destino de prueba')),
          );
        },
      ),
    ),
  );
  await tester.pumpAndSettle();

  return container;
}

Future<void> _tapKey(WidgetTester tester, String key) async {
  final finder = find.byKey(ValueKey(key));
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _selectRecipient(WidgetTester tester, GiftRecipient recipient) {
  return _tapKey(tester, 'search-recipient-${recipient.name}');
}

Future<void> _selectOccasion(WidgetTester tester, GiftOccasion occasion) {
  return _tapKey(tester, 'search-occasion-${occasion.name}');
}

Future<void> _openMoreOptions(WidgetTester tester) {
  return _tapKey(tester, 'search-more-options');
}

Future<void> _enterBudget(WidgetTester tester, String value) async {
  final field = find.byKey(const ValueKey('search-budget-field'));
  await tester.ensureVisible(field);
  await tester.pumpAndSettle();
  await tester.enterText(field, value);
  await tester.pump();
}

Future<void> _submit(WidgetTester tester) {
  return _tapKey(tester, 'search-submit-button');
}

void _setViewport(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void _setTextScale(WidgetTester tester, double scale) {
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}

void main() {
  testWidgets('renderiza las secciones principales de Search', (tester) async {
    await _pumpSearch(tester);

    expect(find.text('Encuentra el regalo ideal'), findsOneWidget);
    expect(find.text('¿Para quién es? *'), findsOneWidget);
    expect(find.text('¿Cuál es la ocasión? *'), findsOneWidget);
    expect(find.text('Presupuesto máximo *'), findsOneWidget);
    expect(find.text('¿Qué le gusta?'), findsOneWidget);
    expect(find.text('Más opciones'), findsOneWidget);
    expect(find.text('Buscar regalos'), findsOneWidget);
    expect(find.text('Limpiar'), findsOneWidget);

    for (final recipient in GiftRecipient.values) {
      expect(
        find.byKey(ValueKey('search-recipient-${recipient.name}')),
        findsOneWidget,
      );
    }
    for (final occasion in GiftOccasion.values) {
      expect(
        find.byKey(ValueKey('search-occasion-${occasion.name}')),
        findsOneWidget,
      );
    }
  });

  testWidgets('el formulario vacío muestra errores inline y no navega', (
    tester,
  ) async {
    RouteSettings? captured;
    await _pumpSearch(tester, onResults: (settings) => captured = settings);

    await _submit(tester);

    expect(find.text('Selecciona para quién es el regalo.'), findsOneWidget);
    expect(find.text('Selecciona una ocasión.'), findsOneWidget);
    expect(find.text('Ingresa un presupuesto.'), findsOneWidget);
    expect(captured, isNull);
  });

  testWidgets('rechaza un presupuesto inválido o no positivo', (tester) async {
    await _pumpSearch(tester);
    await _selectRecipient(tester, GiftRecipient.friend);
    await _selectOccasion(tester, GiftOccasion.birthday);

    await _enterBudget(tester, 'abc');
    await _submit(tester);
    expect(find.text('Ingresa un monto válido.'), findsOneWidget);

    await _enterBudget(tester, '0');
    await _submit(tester);
    expect(find.text('El presupuesto debe ser mayor que 0.'), findsOneWidget);
  });

  testWidgets('acepta presupuesto con coma y genera los criterios', (
    tester,
  ) async {
    RouteSettings? captured;
    await _pumpSearch(tester, onResults: (settings) => captured = settings);

    await _selectRecipient(tester, GiftRecipient.family);
    await _selectOccasion(tester, GiftOccasion.birthday);
    await _enterBudget(tester, '250,50');
    await _submit(tester);

    expect(captured?.name, AppRoutes.productResults);
    final criteria = captured!.arguments! as GiftSearchCriteria;
    expect(criteria.recipientType, GiftRecipient.family);
    expect(criteria.occasion, GiftOccasion.birthday);
    expect(criteria.maxBudget, 250.5);
    expect(criteria.interests, isEmpty);
    expect(criteria.giftFormat, isNull);
    expect(criteria.size, isNull);
    expect(criteria.eventDate, isNull);
    expect(criteria.isPersonalizable, isFalse);
    expect(criteria.onlyAvailable, isFalse);
  });

  testWidgets('los intereses son multiselect', (tester) async {
    RouteSettings? captured;
    await _pumpSearch(tester, onResults: (settings) => captured = settings);

    await _selectRecipient(tester, GiftRecipient.friend);
    await _selectOccasion(tester, GiftOccasion.birthday);
    await _enterBudget(tester, '900');
    await _tapKey(tester, 'search-interest-technology');
    await _tapKey(tester, 'search-interest-gaming');
    await _submit(tester);

    final criteria = captured!.arguments! as GiftSearchCriteria;
    expect(criteria.interests, {GiftInterest.technology, GiftInterest.gaming});
  });

  testWidgets('Más detalles construye edad, formato, tamaño y preferencias', (
    tester,
  ) async {
    RouteSettings? captured;
    await _pumpSearch(tester, onResults: (settings) => captured = settings);

    await _selectRecipient(tester, GiftRecipient.partner);
    await _selectOccasion(tester, GiftOccasion.anniversary);
    await _enterBudget(tester, '500');
    await _openMoreOptions(tester);

    await _tapKey(tester, 'search-age-adult');
    await _tapKey(tester, 'search-format-experience');
    await _tapKey(tester, 'search-size-medium');
    await _tapKey(tester, 'search-personalizable');
    await _tapKey(tester, 'search-local');
    await _tapKey(tester, 'search-fast-delivery');
    await _tapKey(tester, 'search-only-available');
    await _submit(tester);

    final criteria = captured!.arguments! as GiftSearchCriteria;
    expect(criteria.ageRange, GiftAgeRange.adult);
    expect(criteria.giftFormat, GiftFormat.experience);
    expect(criteria.size, GiftSize.medium);
    expect(criteria.isPersonalizable, isTrue);
    expect(criteria.isLocal, isTrue);
    expect(criteria.fastDelivery, isTrue);
    expect(criteria.onlyAvailable, isTrue);
  });

  testWidgets('la fecha opcional se incluye en los criterios', (tester) async {
    RouteSettings? captured;
    await _pumpSearch(tester, onResults: (settings) => captured = settings);

    await _selectRecipient(tester, GiftRecipient.friend);
    await _selectOccasion(tester, GiftOccasion.graduation);
    await _enterBudget(tester, '300');
    await _openMoreOptions(tester);
    await _tapKey(tester, 'search-date-field');
    await tester.tap(find.text('Seleccionar'));
    await tester.pumpAndSettle();
    await _submit(tester);

    final criteria = captured!.arguments! as GiftSearchCriteria;
    expect(criteria.eventDate, isNotNull);
  });

  testWidgets('prefill aplica una vez y limpia el provider', (tester) async {
    final container = await _pumpSearch(
      tester,
      prefill: const SearchPrefill(
        recipientType: GiftRecipient.partner,
        occasion: GiftOccasion.anniversary,
        interests: {GiftInterest.technology},
        giftFormat: GiftFormat.experience,
      ),
    );

    expect(container.read(searchPrefillProvider), isNull);

    final partnerChip = tester.widget<ChoiceChip>(
      find.byKey(const ValueKey('search-recipient-partner')),
    );
    final anniversaryChip = tester.widget<ChoiceChip>(
      find.byKey(const ValueKey('search-occasion-anniversary')),
    );
    final technologyChip = tester.widget<FilterChip>(
      find.byKey(const ValueKey('search-interest-technology')),
    );

    expect(partnerChip.selected, isTrue);
    expect(anniversaryChip.selected, isTrue);
    expect(technologyChip.selected, isTrue);

    await tester.pump();
    expect(
      tester
          .widget<ChoiceChip>(
            find.byKey(const ValueKey('search-recipient-partner')),
          )
          .selected,
      isTrue,
    );
  });

  testWidgets('Limpiar restablece todos los campos y preferencias', (
    tester,
  ) async {
    final container = await _pumpSearch(tester);
    await _selectRecipient(tester, GiftRecipient.friend);
    await _selectOccasion(tester, GiftOccasion.birthday);
    await _enterBudget(tester, '200');
    await _tapKey(tester, 'search-interest-music');
    await _openMoreOptions(tester);
    await _tapKey(tester, 'search-age-adult');
    await _tapKey(tester, 'search-local');
    await _tapKey(tester, 'search-clear-button');

    expect(find.text('Selecciona para quién es el regalo.'), findsNothing);
    expect(container.read(searchPrefillProvider), isNull);

    final budget = tester.widget<TextFormField>(
      find.byKey(const ValueKey('search-budget-field')),
    );
    expect(budget.controller?.text, isEmpty);
  });

  testWidgets('prefill desde Home conserva los campos seleccionados', (
    tester,
  ) async {
    await _pumpSearch(
      tester,
      prefill: const SearchPrefill(
        recipientType: GiftRecipient.family,
        occasion: GiftOccasion.christmas,
      ),
    );

    expect(
      tester
          .widget<ChoiceChip>(
            find.byKey(const ValueKey('search-recipient-family')),
          )
          .selected,
      isTrue,
    );
    expect(
      tester
          .widget<ChoiceChip>(
            find.byKey(const ValueKey('search-occasion-christmas')),
          )
          .selected,
      isTrue,
    );
  });

  for (final size in const [
    Size(320, 640),
    Size(390, 844),
    Size(412, 915),
    Size(800, 800),
  ]) {
    testWidgets('Search no desborda en ${size.width}x${size.height}', (
      tester,
    ) async {
      _setViewport(tester, size);
      await _pumpSearch(tester);

      expect(tester.takeException(), isNull);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  }

  testWidgets('Search soporta text scale 1.3', (tester) async {
    _setViewport(tester, const Size(390, 844));
    _setTextScale(tester, 1.3);
    await _pumpSearch(tester);

    expect(tester.takeException(), isNull);
  });

  testWidgets('Search soporta text scale 2.0 en 320x640', (tester) async {
    _setViewport(tester, const Size(320, 640));
    _setTextScale(tester, 2.0);
    await _pumpSearch(tester);
    await _openMoreOptions(tester);

    expect(tester.takeException(), isNull);
  });
}
