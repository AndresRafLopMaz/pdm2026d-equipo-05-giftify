import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
}
