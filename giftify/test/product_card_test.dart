import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:giftify/core/theme/app_theme.dart';
import 'package:giftify/features/products/widgets/product_card.dart';
import 'package:giftify/features/products/widgets/product_image.dart';
import 'package:giftify/shared/data/mock_products.dart';
import 'package:giftify/shared/enums/gift_category.dart';

void main() {
  testWidgets('muestra metadata legible sin mojibake', (tester) async {
    final product = mockProducts.first;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(body: ProductCard(product: product)),
      ),
    );

    final expectedMetadata =
        '${product.category.label} · ${product.sellerName} '
        '★ ${product.sellerRating.toStringAsFixed(1)}';

    expect(find.text(expectedMetadata), findsOneWidget);
    expect(find.byType(ProductImage), findsOneWidget);
    expect(find.textContaining('Â'), findsNothing);
    expect(find.textContaining('â'), findsNothing);
    expect(find.textContaining('Ã'), findsNothing);
  });
}
