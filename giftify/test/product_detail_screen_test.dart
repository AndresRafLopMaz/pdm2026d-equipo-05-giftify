import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:giftify/app/app_router.dart';
import 'package:giftify/features/cart/screens/cart_screen.dart';
import 'package:giftify/features/products/screens/product_detail_screen.dart';
import 'package:giftify/shared/data/mock_products.dart';
import 'package:giftify/shared/enums/gift_availability.dart';
import 'package:giftify/shared/models/gift_product.dart';

GiftProduct _buildProduct({
  String id = 'test',
  String name = 'Producto de prueba',
  String description = 'Descripción ampliada del producto.',
  double price = 150,
  String category = 'Joyería',
  String size = 'Pequeño',
  GiftAvailability availability = GiftAvailability.inStock,
  String sellerName = 'Vendedor de prueba',
  double sellerRating = 4.5,
  int? estimatedDeliveryDays = 2,
  String? imageAsset,
}) {
  return GiftProduct(
    id: id,
    name: name,
    description: description,
    price: price,
    category: category,
    size: size,
    availability: availability,
    sellerName: sellerName,
    sellerRating: sellerRating,
    suggestedOccasions: const ['Cumpleaños'],
    estimatedDeliveryDays: estimatedDeliveryDays,
    imageAsset: imageAsset,
  );
}

void main() {
  testWidgets('renderiza nombre, precio y descripción', (tester) async {
    final product = _buildProduct(
      name: 'Pulsera artesanal',
      price: 125,
      description: 'Pulsera hecha a mano.',
    );

    await tester.pumpWidget(
      MaterialApp(home: ProductDetailScreen(product: product)),
    );

    expect(find.text('Pulsera artesanal'), findsOneWidget);
    expect(find.text('Q 125.00'), findsOneWidget);
    expect(find.text('Pulsera hecha a mano.'), findsOneWidget);
  });

  testWidgets('muestra vendedor y calificación', (tester) async {
    final product = _buildProduct(
      sellerName: 'Detalles Xela',
      sellerRating: 4.7,
    );

    await tester.pumpWidget(
      MaterialApp(home: ProductDetailScreen(product: product)),
    );

    expect(find.text('Detalles del vendedor'), findsOneWidget);
    expect(find.text('Detalles Xela'), findsOneWidget);
    expect(find.text('4.7 / 5'), findsOneWidget);
  });

  testWidgets('representa la disponibilidad con texto', (tester) async {
    final product = _buildProduct(availability: GiftAvailability.inStock);

    await tester.pumpWidget(
      MaterialApp(home: ProductDetailScreen(product: product)),
    );

    expect(find.text('Disponible'), findsOneWidget);
    expect(find.text('Entrega estimada: 2 días'), findsOneWidget);
  });

  testWidgets('producto agotado deshabilita el botón de agregar', (
    tester,
  ) async {
    final product = _buildProduct(availability: GiftAvailability.outOfStock);

    await tester.pumpWidget(
      MaterialApp(home: ProductDetailScreen(product: product)),
    );

    expect(find.text('Agotado'), findsOneWidget);

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('producto desconocido advierte y no asegura disponibilidad', (
    tester,
  ) async {
    final product = _buildProduct(availability: GiftAvailability.unknown);

    await tester.pumpWidget(
      MaterialApp(home: ProductDetailScreen(product: product)),
    );

    expect(find.text('Por confirmar'), findsOneWidget);
    expect(find.textContaining('aún no está confirmada'), findsOneWidget);

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('producto null no provoca crash y muestra estado seguro', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ProductDetailScreen()));

    expect(
      find.text('No se pudo cargar la información del producto.'),
      findsOneWidget,
    );
    expect(find.widgetWithText(OutlinedButton, 'Volver'), findsOneWidget);
  });

  testWidgets('producto sin imageAsset muestra placeholder', (tester) async {
    final product = _buildProduct(imageAsset: null);

    await tester.pumpWidget(
      MaterialApp(home: ProductDetailScreen(product: product)),
    );

    expect(find.byType(Image), findsNothing);
    expect(find.byIcon(Icons.card_giftcard_rounded), findsOneWidget);
  });

  testWidgets('producto disponible permite agregar al carrito', (tester) async {
    final product = _buildProduct(availability: GiftAvailability.inStock);

    await tester.pumpWidget(
      MaterialApp(home: ProductDetailScreen(product: product)),
    );

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNotNull);
  });

  testWidgets('al agregar navega al carrito con un CartItem', (tester) async {
    final product = mockProducts.firstWhere(
      (item) => item.availability == GiftAvailability.inStock,
    );

    final navigatorKey = GlobalKey<NavigatorState>();

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        initialRoute: AppRoutes.home,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );

    navigatorKey.currentState!.pushNamed(
      AppRoutes.productDetail,
      arguments: product,
    );

    await tester.pumpAndSettle();

    final addButton = find.widgetWithText(FilledButton, 'Agregar al carrito');
    await tester.ensureVisible(addButton);
    await tester.pumpAndSettle();

    await tester.tap(addButton);
    await tester.pumpAndSettle();

    final cart = tester.widget<CartScreen>(find.byType(CartScreen));

    expect(cart.initialItems.length, 1);
    expect(cart.initialItems.first.product, same(product));
  });

  testWidgets('producto con pocas unidades permite agregar', (tester) async {
    final product = _buildProduct(availability: GiftAvailability.lowStock);

    await tester.pumpWidget(
      MaterialApp(home: ProductDetailScreen(product: product)),
    );

    expect(find.text('Pocas unidades'), findsOneWidget);

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNotNull);
  });

  testWidgets('sin estimatedDeliveryDays no muestra plazo de entrega', (
    tester,
  ) async {
    final product = _buildProduct(estimatedDeliveryDays: null);

    await tester.pumpWidget(
      MaterialApp(home: ProductDetailScreen(product: product)),
    );

    expect(find.textContaining('Entrega estimada'), findsNothing);
  });

  testWidgets('no desborda en pantalla móvil pequeña', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final product = _buildProduct(
      name: 'Nombre de producto largo para verificar el ajuste de texto',
      description:
          'Descripción extensa para comprobar que el contenido se adapta '
          'correctamente a pantallas móviles pequeñas sin desbordar.',
    );

    await tester.pumpWidget(
      MaterialApp(home: ProductDetailScreen(product: product)),
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });
}
