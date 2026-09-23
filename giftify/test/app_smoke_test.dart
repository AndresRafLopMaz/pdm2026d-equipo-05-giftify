import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:giftify/app/giftify_app.dart';
import 'package:giftify/features/home/screens/home_screen.dart';

void main() {
  testWidgets('Giftify inicia correctamente en Home', (tester) async {
    await tester.pumpWidget(const GiftifyApp());

    // Comprueba que la aplicación Flutter se creó correctamente.
    expect(find.byType(MaterialApp), findsOneWidget);

    // Comprueba que la ruta inicial corresponde a HomeScreen.
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
