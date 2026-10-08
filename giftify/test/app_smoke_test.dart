import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:giftify/app/giftify_app.dart';
import 'package:giftify/features/auth/screens/register_screen.dart';

void main() {
  testWidgets('Giftify inicia correctamente en Registro', (tester) async {
    await tester.pumpWidget(const GiftifyApp());

    // Comprueba que la aplicación Flutter se creó correctamente.
    expect(find.byType(MaterialApp), findsOneWidget);

    // Comprueba que la ruta inicial corresponde a RegisterScreen.
    expect(find.byType(RegisterScreen), findsOneWidget);
  });
}
