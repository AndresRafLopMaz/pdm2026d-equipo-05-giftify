import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:giftify/app/app_router.dart';
import 'package:giftify/core/theme/app_theme.dart';
import 'package:giftify/features/cart/data/cart_repository.dart';
import 'package:giftify/features/cart/data/cart_store.dart';
import 'package:giftify/features/cart/data/persistent_cart_repository.dart';
import 'package:giftify/features/cart/providers/cart_items_provider.dart';
import 'package:giftify/features/cart/screens/cart_screen.dart';
import 'package:giftify/features/cart/screens/checkout_screen.dart';
import 'package:giftify/shared/data/mock_products.dart';
import 'package:giftify/shared/models/cart_item.dart';

void main() {
  Future<void> pumpCartWithRepository(
    WidgetTester tester,
    CartRepository repository, {
    List<CartItem> initialItems = const [],
    bool settle = true,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [cartRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp(
          theme: appTheme,
          home: CartScreen(initialItems: initialItems),
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      ),
    );
    if (settle) {
      await tester.pumpAndSettle();
    }
  }

  Future<void> pumpCart(WidgetTester tester, List<CartItem> items) async {
    await pumpCartWithRepository(
      tester,
      PersistentCartRepository(store: InMemoryCartStore()),
      initialItems: items,
    );
  }

  Future<void> expireSnackBar(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  }

  String textForKey(WidgetTester tester, String key) {
    return tester.widget<Text>(find.byKey(ValueKey(key))).data!;
  }

  testWidgets('renderiza producto, precio, subtotal y total', (tester) async {
    final product = mockProducts.first;

    await pumpCart(tester, [CartItem(product: product, quantity: 2)]);

    expect(find.text(product.name), findsOneWidget);
    expect(find.text('Precio unitario: Q 125.00'), findsOneWidget);
    expect(textForKey(tester, 'subtotal-${product.id}'), 'Q 250.00');
    expect(textForKey(tester, 'cart-total'), 'Q 250.00');
    expect(
      find.byKey(const ValueKey('product-image-placeholder')),
      findsOneWidget,
    );
  });

  testWidgets('incrementa la cantidad y recalcula importes', (tester) async {
    final product = mockProducts.first;

    await pumpCart(tester, [CartItem(product: product)]);
    await tester.tap(find.byKey(ValueKey('increase-${product.id}')));
    await tester.pumpAndSettle();

    expect(textForKey(tester, 'quantity-${product.id}'), '2');
    expect(textForKey(tester, 'subtotal-${product.id}'), 'Q 250.00');
    expect(textForKey(tester, 'cart-total'), 'Q 250.00');
  });

  testWidgets('disminuye la cantidad y recalcula importes', (tester) async {
    final product = mockProducts.first;

    await pumpCart(tester, [CartItem(product: product, quantity: 2)]);
    await tester.tap(find.byKey(ValueKey('decrease-${product.id}')));
    await tester.pumpAndSettle();

    expect(textForKey(tester, 'quantity-${product.id}'), '1');
    expect(textForKey(tester, 'subtotal-${product.id}'), 'Q 125.00');
    expect(textForKey(tester, 'cart-total'), 'Q 125.00');
  });

  testWidgets('no permite disminuir la cantidad por debajo de uno', (
    tester,
  ) async {
    final product = mockProducts.first;

    await pumpCart(tester, [CartItem(product: product)]);

    final decreaseButton = tester.widget<IconButton>(
      find.byKey(ValueKey('decrease-${product.id}')),
    );
    expect(decreaseButton.onPressed, isNull);
    expect(textForKey(tester, 'quantity-${product.id}'), '1');
  });

  testWidgets('elimina explícitamente un producto', (tester) async {
    final firstProduct = mockProducts.first;
    final secondProduct = mockProducts[1];

    await pumpCart(tester, [
      CartItem(product: firstProduct),
      CartItem(product: secondProduct),
    ]);
    await tester.tap(find.byKey(ValueKey('remove-${firstProduct.id}')));
    await tester.pumpAndSettle();

    expect(find.text(firstProduct.name), findsNothing);
    expect(find.text(secondProduct.name), findsOneWidget);
    expect(textForKey(tester, 'cart-total'), 'Q 95.00');
  });

  testWidgets('eliminar el último producto muestra el carrito vacío', (
    tester,
  ) async {
    final product = mockProducts.first;

    await pumpCart(tester, [CartItem(product: product)]);
    await tester.tap(find.byKey(ValueKey('remove-${product.id}')));
    await tester.pumpAndSettle();

    expect(find.text('Tu carrito está vacío'), findsOneWidget);
    expect(find.byKey(const ValueKey('cart-total')), findsNothing);
    expect(find.text('Q 0.00'), findsNothing);

    final checkoutButton = tester.widget<FilledButton>(
      find.byKey(const ValueKey('checkout-button')),
    );
    expect(checkoutButton.onPressed, isNull);
  });

  testWidgets('renderiza el estado vacío sin una compra válida', (
    tester,
  ) async {
    await pumpCart(tester, const []);

    expect(find.text('Tu carrito está vacío'), findsOneWidget);
    expect(
      find.text('Agrega un regalo para continuar con tu compra.'),
      findsOneWidget,
    );
    expect(find.text('Q 0.00'), findsNothing);
    expect(find.byKey(const ValueKey('cart-total')), findsNothing);
    expect(find.byKey(const ValueKey('cart-filter-all')), findsNothing);
    expect(find.text('No hay productos en esta categoría.'), findsNothing);

    final checkoutButton = tester.widget<FilledButton>(
      find.byKey(const ValueKey('checkout-button')),
    );
    expect(checkoutButton.onPressed, isNull);
  });

  testWidgets('se adapta a una pantalla móvil estrecha', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpCart(tester, [CartItem(product: mockProducts.first)]);

    expect(tester.takeException(), isNull);
    expect(find.text(mockProducts.first.name), findsOneWidget);
    expect(find.byKey(const ValueKey('checkout-button')), findsOneWidget);
  });

  testWidgets('navega a checkout con la lista actualizada', (tester) async {
    final product = mockProducts.first;

    await pumpCart(tester, [CartItem(product: product)]);
    await tester.tap(find.byKey(ValueKey('increase-${product.id}')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('checkout-button')));
    await tester.pumpAndSettle();

    expect(find.byType(CheckoutScreen), findsOneWidget);
    final checkout = tester.widget<CheckoutScreen>(find.byType(CheckoutScreen));
    expect(checkout.items, hasLength(1));
    expect(checkout.items.single.product, same(product));
    expect(checkout.items.single.quantity, 2);
  });

  testWidgets('filtra por categoría sin alterar el total ni lo persistido', (
    tester,
  ) async {
    final store = InMemoryCartStore([
      CartEntry(productId: mockProducts[0].id, quantity: 2),
      CartEntry(productId: mockProducts[1].id, quantity: 1),
      CartEntry(productId: mockProducts[5].id, quantity: 3),
    ]);
    await pumpCartWithRepository(
      tester,
      PersistentCartRepository(store: store),
    );

    expect(find.text(mockProducts[0].name), findsOneWidget);
    expect(find.text(mockProducts[1].name), findsOneWidget);
    expect(find.text(mockProducts[5].name), findsOneWidget);
    expect(textForKey(tester, 'cart-total'), 'Q 780.00');

    await tester.tap(
      find.byKey(ValueKey('cart-filter-category-${mockProducts[1].category}')),
    );
    await tester.pumpAndSettle();

    expect(find.text(mockProducts[0].name), findsNothing);
    expect(find.text(mockProducts[1].name), findsOneWidget);
    expect(find.text(mockProducts[5].name), findsOneWidget);
    expect(textForKey(tester, 'cart-total'), 'Q 780.00');
    expect(find.text('Recargar'), findsNothing);
    expect(find.byKey(const ValueKey('cart-retry-button')), findsNothing);

    await tester.tap(
      find.byKey(ValueKey('cart-filter-category-${mockProducts[0].category}')),
    );
    await tester.pumpAndSettle();

    expect(find.text(mockProducts[0].name), findsOneWidget);
    expect(find.text(mockProducts[1].name), findsNothing);
    expect(find.text(mockProducts[5].name), findsNothing);
    expect(textForKey(tester, 'cart-total'), 'Q 780.00');

    final persisted = await store.load();
    expect(persisted.map((entry) => entry.productId), [
      mockProducts[0].id,
      mockProducts[1].id,
      mockProducts[5].id,
    ]);
    expect(persisted.map((entry) => entry.quantity), [2, 1, 3]);
  });

  testWidgets('muestra filtro sin resultados y permite limpiar el filtro', (
    tester,
  ) async {
    final store = InMemoryCartStore([
      CartEntry(productId: mockProducts[0].id, quantity: 1),
      CartEntry(productId: mockProducts[1].id, quantity: 1),
    ]);
    await pumpCartWithRepository(
      tester,
      PersistentCartRepository(store: store),
    );

    await tester.tap(
      find.byKey(ValueKey('cart-filter-category-${mockProducts[1].category}')),
    );
    await tester.pumpAndSettle();
    expect(find.text(mockProducts[1].name), findsOneWidget);

    await tester.tap(find.byKey(ValueKey('remove-${mockProducts[1].id}')));
    await tester.pumpAndSettle();

    expect(find.text('No hay productos en esta categoría.'), findsOneWidget);
    expect(find.text(mockProducts[0].name), findsNothing);
    expect(textForKey(tester, 'cart-total'), 'Q 125.00');
    expect(
      find.byKey(const ValueKey('clear-cart-filter-empty')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('clear-cart-filter-empty')));
    await tester.pumpAndSettle();

    expect(find.text('No hay productos en esta categoría.'), findsNothing);
    expect(find.text(mockProducts[0].name), findsOneWidget);
    expect(textForKey(tester, 'cart-total'), 'Q 125.00');

    await expireSnackBar(tester);
  });

  testWidgets('usa el id del producto como key y conserva la identidad', (
    tester,
  ) async {
    final products = [mockProducts[0], mockProducts[1], mockProducts[2]];
    final store = InMemoryCartStore([
      for (final product in products)
        CartEntry(productId: product.id, quantity: 1),
    ]);
    await pumpCartWithRepository(
      tester,
      PersistentCartRepository(store: store),
    );

    final cartDismissibles = find.descendant(
      of: find.byKey(const PageStorageKey<String>('cart-list')),
      matching: find.byType(Dismissible),
    );
    final initialKeys = tester
        .widgetList<Dismissible>(cartDismissibles)
        .map((dismissible) => dismissible.key)
        .toList();
    expect(initialKeys, [
      ValueKey(products[0].id),
      ValueKey(products[1].id),
      ValueKey(products[2].id),
    ]);

    await tester.tap(find.byKey(ValueKey('remove-${products[1].id}')));
    await tester.pumpAndSettle();

    final remainingKeys = tester
        .widgetList<Dismissible>(cartDismissibles)
        .map((dismissible) => dismissible.key)
        .toList();
    expect(remainingKeys, [ValueKey(products[0].id), ValueKey(products[2].id)]);
    expect(find.text(products[1].name), findsNothing);
    expect(find.text(products[0].name), findsOneWidget);
    expect(find.text(products[2].name), findsOneWidget);

    final persisted = await store.load();
    expect(persisted.map((entry) => entry.productId), [
      products[0].id,
      products[2].id,
    ]);

    await expireSnackBar(tester);
  });

  testWidgets('swipe elimina y Deshacer restaura datos y total', (
    tester,
  ) async {
    final first = mockProducts[0];
    final second = mockProducts[1];
    final store = InMemoryCartStore([
      CartEntry(productId: first.id, quantity: 2),
      CartEntry(productId: second.id, quantity: 1),
    ]);
    await pumpCartWithRepository(
      tester,
      PersistentCartRepository(store: store),
    );
    expect(textForKey(tester, 'cart-total'), 'Q 345.00');

    await tester.drag(find.byKey(ValueKey(first.id)), const Offset(-500, 0));
    await tester.pumpAndSettle();

    expect(find.text(first.name), findsNothing);
    expect(find.text(second.name), findsOneWidget);
    expect(find.text('Producto eliminado.'), findsOneWidget);
    expect(find.text('Deshacer'), findsOneWidget);
    expect(textForKey(tester, 'cart-total'), 'Q 95.00');

    var persisted = await store.load();
    expect(persisted.map((entry) => entry.productId), [second.id]);

    await tester.tap(find.text('Deshacer'));
    await tester.pumpAndSettle();

    expect(find.text(first.name), findsOneWidget);
    expect(textForKey(tester, 'quantity-${first.id}'), '2');
    expect(textForKey(tester, 'cart-total'), 'Q 345.00');

    persisted = await store.load();
    expect(persisted.map((entry) => entry.productId), [first.id, second.id]);
    expect(persisted.map((entry) => entry.quantity), [2, 1]);

    await expireSnackBar(tester);
  });

  testWidgets('si el borrado falla, el elemento permanece', (tester) async {
    final first = mockProducts[0];
    final second = mockProducts[1];
    final store = _FailingSaveCartStore([
      CartEntry(productId: first.id, quantity: 1),
      CartEntry(productId: second.id, quantity: 1),
    ]);
    await pumpCartWithRepository(
      tester,
      PersistentCartRepository(store: store),
    );

    await tester.tap(find.byKey(ValueKey('remove-${first.id}')));
    await tester.pumpAndSettle();

    expect(find.text(first.name), findsOneWidget);
    expect(find.text(second.name), findsOneWidget);
    expect(
      find.text('No se pudo eliminar el producto. Inténtalo de nuevo.'),
      findsOneWidget,
    );
    expect(find.text('Deshacer'), findsNothing);
    expect(textForKey(tester, 'cart-total'), 'Q 220.00');

    final persisted = await store.load();
    expect(persisted.map((entry) => entry.productId), [first.id, second.id]);

    await expireSnackBar(tester);
  });

  testWidgets('si Deshacer falla, comunica el error y no restaura la fila', (
    tester,
  ) async {
    final first = mockProducts[0];
    final second = mockProducts[1];
    final store = _FailingRestoreCartStore([
      CartEntry(productId: first.id, quantity: 2),
      CartEntry(productId: second.id, quantity: 1),
    ]);
    await pumpCartWithRepository(
      tester,
      PersistentCartRepository(store: store),
    );

    await tester.tap(find.byKey(ValueKey('remove-${first.id}')));
    await tester.pumpAndSettle();
    expect(find.text(first.name), findsNothing);
    expect(textForKey(tester, 'cart-total'), 'Q 95.00');

    await tester.tap(find.text('Deshacer'));
    await tester.pumpAndSettle();

    expect(
      find.text('No se pudo deshacer la eliminación. Inténtalo de nuevo.'),
      findsOneWidget,
    );
    expect(find.text(first.name), findsNothing);
    expect(textForKey(tester, 'cart-total'), 'Q 95.00');

    final persisted = await store.load();
    expect(persisted.map((entry) => entry.productId), [second.id]);

    await expireSnackBar(tester);
  });

  testWidgets('la carga inicial se fusiona con el carrito persistido', (
    tester,
  ) async {
    final first = mockProducts[0];
    final second = mockProducts[1];
    final store = InMemoryCartStore([
      CartEntry(productId: first.id, quantity: 1),
    ]);
    await pumpCartWithRepository(
      tester,
      PersistentCartRepository(store: store),
      initialItems: [
        CartItem(product: first),
        CartItem(product: second, quantity: 2),
      ],
    );

    expect(find.text(first.name), findsOneWidget);
    expect(find.text(second.name), findsOneWidget);
    expect(textForKey(tester, 'quantity-${first.id}'), '2');
    expect(textForKey(tester, 'quantity-${second.id}'), '2');
    expect(textForKey(tester, 'cart-total'), 'Q 440.00');

    final persisted = await store.load();
    expect(persisted.map((entry) => entry.productId), [first.id, second.id]);
    expect(persisted.map((entry) => entry.quantity), [2, 2]);
  });

  testWidgets('muestra Loading mientras el repositorio carga', (tester) async {
    final store = _DeferredLoadCartStore();
    await pumpCartWithRepository(
      tester,
      PersistentCartRepository(store: store),
      settle: false,
    );

    expect(find.byKey(const ValueKey('cart-loading')), findsOneWidget);
    expect(find.text('Cargando carrito…'), findsOneWidget);

    store.loadCompleter.complete([
      CartEntry(productId: mockProducts[0].id, quantity: 1),
    ]);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('cart-loading')), findsNothing);
    expect(find.text(mockProducts[0].name), findsOneWidget);
    expect(textForKey(tester, 'cart-total'), 'Q 125.00');
  });

  testWidgets('muestra error, reintenta manualmente y no reintenta solo', (
    tester,
  ) async {
    final store = _ToggleLoadCartStore([
      CartEntry(productId: mockProducts[0].id, quantity: 1),
    ]);
    await pumpCartWithRepository(
      tester,
      PersistentCartRepository(store: store),
    );

    expect(find.byKey(const ValueKey('cart-error')), findsOneWidget);
    expect(find.text('No pudimos cargar el carrito.'), findsOneWidget);
    expect(find.byKey(const ValueKey('cart-retry-button')), findsOneWidget);
    final attemptsAfterError = store.loadCalls;

    await tester.pump(const Duration(seconds: 5));
    expect(store.loadCalls, attemptsAfterError);
    expect(find.byKey(const ValueKey('cart-error')), findsOneWidget);

    store.shouldFail = false;
    await tester.tap(find.byKey(const ValueKey('cart-retry-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('cart-error')), findsNothing);
    expect(find.text(mockProducts[0].name), findsOneWidget);
    expect(textForKey(tester, 'cart-total'), 'Q 125.00');
  });

  testWidgets('si falla la cantidad, no cambia el valor mostrado', (
    tester,
  ) async {
    final product = mockProducts[0];
    final store = _FailingSaveCartStore([
      CartEntry(productId: product.id, quantity: 1),
    ]);
    await pumpCartWithRepository(
      tester,
      PersistentCartRepository(store: store),
    );

    await tester.tap(find.byKey(ValueKey('increase-${product.id}')));
    await tester.pumpAndSettle();

    expect(textForKey(tester, 'quantity-${product.id}'), '1');
    expect(textForKey(tester, 'cart-total'), 'Q 125.00');
    expect(
      find.text('No se pudo actualizar la cantidad. Inténtalo de nuevo.'),
      findsOneWidget,
    );
    expect((await store.load()).single.quantity, 1);

    await expireSnackBar(tester);
  });

  testWidgets('checkout recibe todos los items aunque haya filtro activo', (
    tester,
  ) async {
    final store = InMemoryCartStore([
      CartEntry(productId: mockProducts[0].id, quantity: 2),
      CartEntry(productId: mockProducts[1].id, quantity: 1),
      CartEntry(productId: mockProducts[5].id, quantity: 3),
    ]);
    await pumpCartWithRepository(
      tester,
      PersistentCartRepository(store: store),
    );

    await tester.tap(
      find.byKey(ValueKey('cart-filter-category-${mockProducts[1].category}')),
    );
    await tester.pumpAndSettle();
    expect(textForKey(tester, 'cart-total'), 'Q 780.00');

    await tester.tap(find.byKey(const ValueKey('checkout-button')));
    await tester.pumpAndSettle();

    final checkout = tester.widget<CheckoutScreen>(find.byType(CheckoutScreen));
    expect(checkout.items.map((item) => item.product.id), [
      mockProducts[0].id,
      mockProducts[1].id,
      mockProducts[5].id,
    ]);
    expect(checkout.items.map((item) => item.quantity), [2, 1, 3]);
    expect(
      checkout.items.fold<double>(0, (total, item) => total + item.subtotal),
      780,
    );
  });

  testWidgets('flujo responsive 320x640 con filtro, Deshacer y checkout', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final store = InMemoryCartStore([
      CartEntry(productId: mockProducts[0].id, quantity: 2),
      CartEntry(productId: mockProducts[1].id, quantity: 1),
      CartEntry(productId: mockProducts[5].id, quantity: 3),
    ]);
    await pumpCartWithRepository(
      tester,
      PersistentCartRepository(store: store),
    );

    expect(tester.takeException(), isNull);
    expect(find.text(mockProducts[0].name), findsOneWidget);
    expect(textForKey(tester, 'cart-total'), 'Q 780.00');
    expect(
      find.byKey(const ValueKey('cart-filter-all')).hitTestable(),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(ValueKey('cart-filter-category-${mockProducts[1].category}')),
    );
    await tester.pumpAndSettle();
    expect(find.text(mockProducts[0].name), findsNothing);
    expect(find.text(mockProducts[1].name), findsOneWidget);
    expect(textForKey(tester, 'cart-total'), 'Q 780.00');

    await tester.tap(find.byKey(const ValueKey('cart-filter-all')));
    await tester.pumpAndSettle();
    expect(find.text(mockProducts[0].name), findsOneWidget);

    await tester.tap(find.byKey(ValueKey('remove-${mockProducts[0].id}')));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Deshacer').hitTestable(), findsOneWidget);
    expect(textForKey(tester, 'cart-total'), 'Q 530.00');

    await tester.tap(find.text('Deshacer'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(textForKey(tester, 'cart-total'), 'Q 780.00');
    expect(
      find.byKey(const ValueKey('checkout-button')).hitTestable(),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('checkout-button')));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    final checkout = tester.widget<CheckoutScreen>(find.byType(CheckoutScreen));
    expect(checkout.items, hasLength(3));
    expect(
      checkout.items.fold<double>(0, (total, item) => total + item.subtotal),
      780,
    );

    await expireSnackBar(tester);
  });
}

class _DeferredLoadCartStore extends CartStore {
  final loadCompleter = Completer<List<CartEntry>>();

  @override
  Future<List<CartEntry>> load() => loadCompleter.future;

  @override
  Future<void> save(List<CartEntry> entries) async {}
}

class _ToggleLoadCartStore extends CartStore {
  _ToggleLoadCartStore(this.entries);

  final List<CartEntry> entries;
  bool shouldFail = true;
  int loadCalls = 0;

  @override
  Future<List<CartEntry>> load() async {
    loadCalls++;
    if (shouldFail) {
      throw StateError('Fallo de lectura');
    }
    return List<CartEntry>.of(entries);
  }

  @override
  Future<void> save(List<CartEntry> entries) async {}
}

class _FailingSaveCartStore extends CartStore {
  _FailingSaveCartStore(this.entries);

  final List<CartEntry> entries;

  @override
  Future<List<CartEntry>> load() async => List<CartEntry>.of(entries);

  @override
  Future<void> save(List<CartEntry> entries) {
    throw StateError('Fallo de escritura');
  }
}

class _FailingRestoreCartStore extends CartStore {
  _FailingRestoreCartStore(List<CartEntry> entries)
    : _entries = List<CartEntry>.of(entries);

  List<CartEntry> _entries;
  int saveCalls = 0;

  @override
  Future<List<CartEntry>> load() async => List<CartEntry>.of(_entries);

  @override
  Future<void> save(List<CartEntry> entries) async {
    saveCalls++;
    if (saveCalls >= 2) {
      throw StateError('Fallo al restaurar');
    }
    _entries = List<CartEntry>.of(entries);
  }
}
