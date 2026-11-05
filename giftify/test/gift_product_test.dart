import 'package:flutter_test/flutter_test.dart';
import 'package:giftify/shared/enums/gift_availability.dart';
import 'package:giftify/shared/enums/gift_category.dart';
import 'package:giftify/shared/enums/gift_format.dart';
import 'package:giftify/shared/enums/gift_size.dart';
import 'package:giftify/shared/models/gift_product.dart';

void main() {
  test('GiftProduct V2 conserva defaults compatibles', () {
    const product = GiftProduct(
      id: 'legacy',
      name: 'Producto legado',
      description: 'Sin metadata adicional.',
      price: 100,
      category: GiftCategory.jewelry,
      size: GiftSize.small,
      availability: GiftAvailability.inStock,
      sellerName: 'Vendedor',
      sellerRating: 4.5,
    );

    expect(product.occasions, isEmpty);
    expect(product.recipientTypes, isEmpty);
    expect(product.ageRanges, isEmpty);
    expect(product.interests, isEmpty);
    expect(product.giftFormat, GiftFormat.physical);
    expect(product.isPersonalizable, isFalse);
    expect(product.isLocal, isFalse);
    expect(product.isAvailable, isTrue);
  });

  test('los labels de los enums son humanos', () {
    expect(GiftCategory.jewelry.label, 'Joyería');
    expect(GiftSize.medium.label, 'Mediano');
    expect(GiftFormat.experience.label, 'Experiencia');
  });
}
