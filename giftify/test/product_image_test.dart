import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:giftify/core/theme/app_theme.dart';
import 'package:giftify/features/products/data/category_visuals.dart';
import 'package:giftify/features/products/widgets/product_image.dart';
import 'package:giftify/shared/enums/gift_availability.dart';
import 'package:giftify/shared/enums/gift_category.dart';
import 'package:giftify/shared/enums/gift_size.dart';
import 'package:giftify/shared/models/gift_product.dart';

GiftProduct _product(GiftCategory category, {String? imageAsset}) {
  return GiftProduct(
    id: 'test-${category.name}',
    name: 'Regalo de ${category.label}',
    description: 'Producto de prueba',
    price: 100,
    category: category,
    size: GiftSize.medium,
    availability: GiftAvailability.inStock,
    sellerName: 'Tienda',
    sellerRating: 4.8,
    imageAsset: imageAsset,
  );
}

Future<void> _pumpImage(
  WidgetTester tester,
  GiftProduct product, {
  ThemeData? theme,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: theme ?? AppTheme.lightTheme,
      home: Scaffold(
        body: Center(
          child: ProductImage(product: product, width: 92, height: 92),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  test('las 10 categorías tienen asset path e icono exhaustivos', () {
    for (final category in GiftCategory.values) {
      final path = CategoryVisuals.assetPathFor(category);
      expect(path, 'assets/images/categories/${category.name}.webp');
      expect(CategoryVisuals.iconFor(category), isNotNull);
    }
  });

  test('sin assets locales, el resolver no intenta cargar archivos', () {
    expect(CategoryVisuals.localAssetsAvailable, isFalse);
    for (final category in GiftCategory.values) {
      expect(CategoryVisuals.bundledAssetFor(category), isNull);
    }
  });

  testWidgets('sin imageAsset usa el icono de su categoría', (tester) async {
    for (final category in GiftCategory.values) {
      final product = _product(category);
      await _pumpImage(tester, product);

      expect(find.byIcon(CategoryVisuals.iconFor(category)), findsOneWidget);
      expect(find.byType(Image), findsNothing);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('el fallback funciona en dark', (tester) async {
    final product = _product(GiftCategory.beauty);
    await _pumpImage(tester, product, theme: AppTheme.darkTheme);

    expect(
      find.byIcon(CategoryVisuals.iconFor(product.category)),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('un asset faltante cae al fallback sin romper', (tester) async {
    final product = _product(
      GiftCategory.technology,
      imageAsset: 'assets/images/categories/missing.webp',
    );

    await _pumpImage(tester, product);

    expect(
      find.byIcon(CategoryVisuals.iconFor(product.category)),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
