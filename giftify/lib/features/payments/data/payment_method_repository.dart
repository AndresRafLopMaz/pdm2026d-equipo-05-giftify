import '../../../shared/enums/payment_brand.dart';
import '../../../shared/models/payment_method.dart';

abstract class PaymentMethodRepository {
  Future<List<PaymentMethod>> list();

  Future<PaymentMethod> create({
    required String holderName,
    required PaymentBrand brand,
    required String last4,
    required int expiryMonth,
    required int expiryYear,
    bool isDefault = false,
  });

  Future<void> delete(String id);

  Future<void> setDefault(String id);
}
