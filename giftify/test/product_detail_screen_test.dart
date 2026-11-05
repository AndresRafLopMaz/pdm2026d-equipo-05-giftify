import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:giftify/app/app_router.dart';
import 'package:giftify/app/main_shell.dart';
import 'package:giftify/core/theme/app_theme.dart';
import 'package:giftify/features/cart/data/cart_repository.dart';
import 'package:giftify/features/cart/data/cart_store.dart';
import 'package:giftify/features/cart/data/persistent_cart_repository.dart';
import 'package:giftify/features/cart/providers/cart_items_provider.dart';
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

Widget _detailApp(GiftProduct? product, {CartRepository? repository}) {
  return ProviderScope(
    overrides: [
      cartRepositoryProvider.overrideWithValue(
        repository ?? PersistentCartRepository(store: InMemoryCartStore()),
      ),
    ],
    child: MaterialApp(
      theme: appTheme,
      home: ProductDetailScreen(product: product),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  testWidgets('renderiza nombre, precio y descripción', (tester) async {
    final product = _buildProduct(
      name: 'Pulsera artesanal',
      price: 125,
      description: 'Pulsera hecha a mano.',
    );

    await tester.pumpWidget(_detailApp(product));

    expect(find.text('Pulsera artesanal'), findsOneWidget);
    expect(find.text('Q 125.00'), findsOneWidget);
    expect(find.text('Pulsera hecha a mano.'), findsOneWidget);
  });

  testWidgets('muestra vendedor y calificación', (tester) async {
    final product = _buildProduct(
      sellerName: 'Detalles Xela',
      sellerRating: 4.7,
    );

    await tester.pumpWidget(_detailApp(product));

    expect(find.text('Vendedor'), findsOneWidget);
    expect(find.text('Detalles Xela'), findsOneWidget);
    expect(find.text('4.7 / 5'), findsOneWidget);
  });

  testWidgets('representa la disponibilidad con texto', (tester) async {
    final product = _buildProduct(availability: GiftAvailability.inStock);

    await tester.pumpWidget(_detailApp(product));

    expect(find.text('Disponible'), findsOneWidget);
    expect(find.textContaining('Entrega estimada: 2 días'), findsOneWidget);
  });

  testWidgets('producto agotado deshabilita el botón de agregar', (
    tester,
  ) async {
    final product = _buildProduct(availability: GiftAvailability.outOfStock);

    await tester.pumpWidget(_detailApp(product));

    expect(find.text('Agotado'), findsOneWidget);

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('producto desconocido advierte y no asegura disponibilidad', (
    tester,
  ) async {
    final product = _buildProduct(availability: GiftAvailability.unknown);

    await tester.pumpWidget(_detailApp(product));

    expect(find.text('Por confirmar'), findsOneWidget);
    expect(find.textContaining('aún no está confirmada'), findsOneWidget);

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('producto null no provoca crash y muestra estado seguro', (
    tester,
  ) async {
    await tester.pumpWidget(_detailApp(null));

    expect(
      find.text('No se pudo cargar la información del producto.'),
      findsOneWidget,
    );
    expect(find.widgetWithText(OutlinedButton, 'Volver'), findsOneWidget);
  });

  testWidgets('producto sin imageAsset muestra placeholder', (tester) async {
    final product = _buildProduct(imageAsset: null);

    await tester.pumpWidget(_detailApp(product));

    expect(find.byType(Image), findsNothing);
    expect(find.byIcon(Icons.card_giftcard_rounded), findsOneWidget);
  });

  testWidgets('producto disponible permite agregar al carrito', (tester) async {
    final product = _buildProduct(availability: GiftAvailability.inStock);

    await tester.pumpWidget(_detailApp(product));

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNotNull);
  });

  testWidgets('el CTA queda fijo en el scaffold inferior', (tester) async {
    final product = _buildProduct(availability: GiftAvailability.inStock);

    await tester.pumpWidget(_detailApp(product));

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.bottomNavigationBar, isNotNull);
    expect(find.byKey(const ValueKey('detail-add-to-cart')), findsOneWidget);
  });

  testWidgets('al agregar permanece en Detail y muestra el SnackBar', (
    tester,
  ) async {
    final product = mockProducts.firstWhere(
      (item) => item.availability == GiftAvailability.inStock,
    );
    final store = InMemoryCartStore();

    await tester.pumpWidget(
      _detailApp(product, repository: PersistentCartRepository(store: store)),
    );
    await tester.pumpAndSettle();

    final addButton = find.widgetWithText(FilledButton, 'Agregar al carrito');
    await tester.ensureVisible(addButton);
    await tester.pumpAndSettle();

    await tester.tap(addButton);
    await tester.pumpAndSettle();

    expect(find.byType(ProductDetailScreen), findsOneWidget);
    expect(find.text('Producto agregado al carrito.'), findsOneWidget);
    expect(find.text('Ver carrito'), findsOneWidget);

    final persisted = await store.load();
    expect(persisted, hasLength(1));
    expect(persisted.single.productId, product.id);
    expect(persisted.single.quantity, 1);
  });

  testWidgets('si falla el guardado, permanece en Detail y muestra error', (
    tester,
  ) async {
    final product = mockProducts.firstWhere(
      (item) => item.availability == GiftAvailability.inStock,
    );
    final store = _FailingSaveCartStore();

    await tester.pumpWidget(
      _detailApp(product, repository: PersistentCartRepository(store: store)),
    );
    await tester.pumpAndSettle();

    final addButton = find.widgetWithText(FilledButton, 'Agregar al carrito');
    await tester.ensureVisible(addButton);
    await tester.pumpAndSettle();

    await tester.tap(addButton);
    await tester.pumpAndSettle();

    expect(find.byType(ProductDetailScreen), findsOneWidget);
    expect(
      find.text('No se pudo agregar el producto. Inténtalo de nuevo.'),
      findsOneWidget,
    );
    expect(find.text('Producto agregado al carrito.'), findsNothing);
  });

  testWidgets('Ver carrito abre la tab Carrito y no duplica el estado', (
    tester,
  ) async {
    final product = mockProducts.firstWhere(
      (item) => item.availability == GiftAvailability.inStock,
    );
    final store = InMemoryCartStore();
    final navigatorKey = GlobalKey<NavigatorState>();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cartRepositoryProvider.overrideWithValue(
            PersistentCartRepository(store: store),
          ),
        ],
        child: MaterialApp(
          theme: appTheme,
          navigatorKey: navigatorKey,
          home: const MainShell(),
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      ),
    );
    await tester.pumpAndSettle();

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

    await tester.tap(find.text('Ver carrito'));
    await tester.pumpAndSettle();

    expect(find.byType(MainShell), findsOneWidget);
    expect(find.byType(CartScreen), findsOneWidget);
    expect(navigatorKey.currentState!.canPop(), isFalse);
    expect(find.text(product.name), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(ValueKey('quantity-${product.id}'))).data,
      '1',
    );

    final persisted = await store.load();
    expect(persisted, hasLength(1));
    expect(persisted.single.productId, product.id);
    expect(persisted.single.quantity, 1);
  });

  testWidgets('producto con pocas unidades permite agregar', (tester) async {
    final product = _buildProduct(availability: GiftAvailability.lowStock);

    await tester.pumpWidget(_detailApp(product));

    expect(find.text('Pocas unidades'), findsOneWidget);

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNotNull);
  });

  testWidgets('sin estimatedDeliveryDays no muestra plazo de entrega', (
    tester,
  ) async {
    final product = _buildProduct(estimatedDeliveryDays: null);

    await tester.pumpWidget(_detailApp(product));

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

    await tester.pumpWidget(_detailApp(product));

    expect(tester.takeException(), isNull);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });
}

class _FailingSaveCartStore extends CartStore {
  @override
  Future<List<CartEntry>> load() async => const [];

  @override
  Future<void> save(List<CartEntry> entries) {
    throw StateError('Fallo al guardar el carrito.');
  }
}
