import 'package:giftify/features/payments/data/payment_method_errors.dart';
import 'package:giftify/features/payments/data/payment_method_repository.dart';
import 'package:giftify/shared/enums/payment_brand.dart';
import 'package:giftify/shared/models/payment_method.dart';

class FakePaymentMethodRepository implements PaymentMethodRepository {
  FakePaymentMethodRepository({
    required this.userId,
    List<PaymentMethod> initial = const [],
  }) : _methods = List<PaymentMethod>.of(initial);

  final int userId;
  final List<PaymentMethod> _methods;
  int _nextId = 1;
  bool failList = false;
  bool failCreate = false;
  bool failDelete = false;

  List<PaymentMethod> get current => List<PaymentMethod>.unmodifiable(_methods);

  @override
  Future<List<PaymentMethod>> list() async {
    if (failList) {
      throw const PaymentMethodStorageException();
    }
    final sorted = List<PaymentMethod>.of(_methods)
      ..sort((a, b) {
        if (a.isDefault != b.isDefault) {
          return a.isDefault ? -1 : 1;
        }
        final brand = a.brand.name.compareTo(b.brand.name);
        if (brand != 0) {
          return brand;
        }
        return a.last4.compareTo(b.last4);
      });
    return List<PaymentMethod>.unmodifiable(sorted);
  }

  @override
  Future<PaymentMethod> create({
    required String holderName,
    required PaymentBrand brand,
    required String last4,
    required int expiryMonth,
    required int expiryYear,
    bool isDefault = false,
  }) async {
    if (failCreate) {
      throw const PaymentMethodStorageException();
    }
    if (holderName.trim().isEmpty ||
        !RegExp(r'^[0-9]{4}$').hasMatch(last4) ||
        expiryMonth < 1 ||
        expiryMonth > 12) {
      throw const InvalidPaymentMethodException('Datos inválidos.');
    }

    final makeDefault = isDefault || _methods.isEmpty;
    if (makeDefault) {
      for (var index = 0; index < _methods.length; index++) {
        _methods[index] = _copy(_methods[index], isDefault: false);
      }
    }

    final method = PaymentMethod(
      id: 'pay-fake-${_nextId++}',
      userId: userId,
      holderName: holderName.trim(),
      brand: brand,
      last4: last4,
      expiryMonth: expiryMonth,
      expiryYear: expiryYear,
      isDefault: makeDefault,
    );
    _methods.add(method);
    return method;
  }

  @override
  Future<void> delete(String id) async {
    if (failDelete) {
      throw const PaymentMethodStorageException();
    }
    final index = _methods.indexWhere((method) => method.id == id);
    if (index < 0) {
      throw const PaymentMethodNotFoundException();
    }
    final wasDefault = _methods[index].isDefault;
    _methods.removeAt(index);
    if (!wasDefault || _methods.isEmpty) {
      return;
    }
    _methods[0] = _copy(_methods[0], isDefault: true);
  }

  @override
  Future<void> setDefault(String id) async {
    final index = _methods.indexWhere((method) => method.id == id);
    if (index < 0) {
      throw const PaymentMethodNotFoundException();
    }
    for (var i = 0; i < _methods.length; i++) {
      _methods[i] = _copy(_methods[i], isDefault: _methods[i].id == id);
    }
  }

  PaymentMethod _copy(PaymentMethod method, {required bool isDefault}) {
    return PaymentMethod(
      id: method.id,
      userId: method.userId,
      holderName: method.holderName,
      brand: method.brand,
      last4: method.last4,
      expiryMonth: method.expiryMonth,
      expiryYear: method.expiryYear,
      isDefault: isDefault,
    );
  }
}
