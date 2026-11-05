import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:giftify/app/app_router.dart';
import 'package:giftify/app/auth_gate.dart';
import 'package:giftify/core/theme/app_theme.dart';
import 'package:giftify/features/addresses/providers/addresses_provider.dart';
import 'package:giftify/features/addresses/screens/address_list_screen.dart';
import 'package:giftify/features/auth/screens/login_screen.dart';
import 'package:giftify/features/payments/providers/payment_methods_provider.dart';
import 'package:giftify/features/payments/screens/payment_methods_screen.dart';
import 'package:giftify/features/profile/screens/profile_screen.dart';
import 'package:giftify/features/settings/screens/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/auth_test_harness.dart';
import '../helpers/fake_address_repository.dart';
import '../helpers/fake_payment_method_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<AuthTestHarness> authenticatedHarness() async {
    final harness = AuthTestHarness();
    final user = harness.repository.seedUser(
      name: 'Andrés López',
      email: 'andres@mail.com',
    );
    harness.session.userId = user.id;
    return harness;
  }

  Future<void> pumpProfile(
    WidgetTester tester,
    AuthTestHarness harness, {
    FakeAddressRepository? addressRepository,
    FakePaymentMethodRepository? paymentRepository,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...harness.overrides,
          if (addressRepository != null)
            addressRepositoryProvider.overrideWithValue(addressRepository),
          if (paymentRepository != null)
            paymentMethodRepositoryProvider.overrideWithValue(
              paymentRepository,
            ),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const AuthGate(authenticatedChild: ProfileScreen()),
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('muestra usuario real, email e iniciales', (tester) async {
    final harness = await authenticatedHarness();
    await pumpProfile(tester, harness);

    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(find.text('Andrés López'), findsOneWidget);
    expect(find.text('andres@mail.com'), findsOneWidget);
    expect(find.text('AL'), findsOneWidget);
    expect(find.text('Mis direcciones'), findsOneWidget);
    expect(find.text('Métodos de pago'), findsOneWidget);
    expect(find.text('Apariencia'), findsOneWidget);
    expect(find.text('Cerrar sesión'), findsOneWidget);
  });

  testWidgets('no expone datos técnicos ni opciones futuras', (tester) async {
    final harness = await authenticatedHarness();
    await pumpProfile(tester, harness);

    expect(find.textContaining('password'), findsNothing);
    expect(find.textContaining('hash'), findsNothing);
    expect(find.textContaining('salt'), findsNothing);
    expect(find.textContaining('Editar perfil'), findsNothing);
    expect(find.textContaining('Fecha de nacimiento'), findsNothing);
  });

  testWidgets('Mis direcciones abre el CRUD existente', (tester) async {
    final harness = await authenticatedHarness();
    await pumpProfile(
      tester,
      harness,
      addressRepository: FakeAddressRepository(),
    );

    await tester.tap(find.byKey(const ValueKey('profile-addresses')));
    await tester.pumpAndSettle();

    expect(find.byType(AddressListScreen), findsOneWidget);
    expect(find.text('Mis direcciones'), findsOneWidget);
  });

  testWidgets('Métodos de pago abre Payments', (tester) async {
    final harness = await authenticatedHarness();
    await pumpProfile(
      tester,
      harness,
      paymentRepository: FakePaymentMethodRepository(userId: 1),
    );

    await tester.tap(find.byKey(const ValueKey('profile-payment-methods')));
    await tester.pumpAndSettle();

    expect(find.byType(PaymentMethodsScreen), findsOneWidget);
  });

  testWidgets('Apariencia abre Settings', (tester) async {
    final harness = await authenticatedHarness();
    await pumpProfile(tester, harness);

    await tester.tap(find.byKey(const ValueKey('profile-settings')));
    await tester.pumpAndSettle();

    expect(find.byType(SettingsScreen), findsOneWidget);
    expect(find.text('Configuración'), findsOneWidget);
  });

  testWidgets('logout vuelve a Login sin stack extra', (tester) async {
    final harness = await authenticatedHarness();
    await pumpProfile(tester, harness);

    final logoutButton = find.byKey(const ValueKey('profile-logout-button'));
    await tester.ensureVisible(logoutButton);
    await tester.pumpAndSettle();
    await tester.tap(logoutButton);
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(ProfileScreen), findsNothing);
    expect(harness.session.userId, isNull);

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    expect(navigator.canPop(), isFalse);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(ProfileScreen), findsNothing);
    expect(find.text('Ruta no encontrada'), findsNothing);
  });

  testWidgets('Profile es responsive en 320x640', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final harness = await authenticatedHarness();
    await pumpProfile(tester, harness);

    expect(tester.takeException(), isNull);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.byKey(const ValueKey('profile-logout-button')), findsOneWidget);
  });

  testWidgets('Profile soporta text scale 2.0', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    final harness = await authenticatedHarness();
    await pumpProfile(tester, harness);

    expect(tester.takeException(), isNull);
    expect(find.text('Andrés López'), findsOneWidget);
  });
}
