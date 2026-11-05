import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:giftify/app/app_router.dart';
import 'package:giftify/app/giftify_app.dart';
import 'package:giftify/features/auth/screens/register_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  testWidgets('Giftify inicia correctamente en Registro', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: GiftifyApp()));

    // Comprueba que la aplicación Flutter se creó correctamente.
    expect(find.byType(MaterialApp), findsOneWidget);

    // Comprueba que la ruta inicial corresponde a RegisterScreen.
    expect(find.byType(RegisterScreen), findsOneWidget);
  });

  testWidgets('el stack inicial no contiene una ruta desconocida', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: GiftifyApp()));
    await tester.pumpAndSettle();

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));

    expect(find.byType(RegisterScreen), findsOneWidget);
    expect(navigator.canPop(), isFalse);
    expect(find.text('Ruta no encontrada'), findsNothing);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.byType(RegisterScreen), findsOneWidget);
    expect(find.text('Ruta no encontrada'), findsNothing);
  });

  testWidgets('una ruta realmente desconocida conserva el fallback', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          initialRoute: '/ruta-inexistente',
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ruta no encontrada'), findsOneWidget);
  });
}
