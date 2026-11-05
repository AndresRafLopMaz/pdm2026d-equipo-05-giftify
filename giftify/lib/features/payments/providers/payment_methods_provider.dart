import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_providers.dart';
import '../../../shared/enums/payment_brand.dart';
import '../../../shared/models/payment_method.dart';
import '../../auth/providers/current_user_provider.dart';
import '../../ownership/providers/ownership_providers.dart';
import '../data/payment_method_repository.dart';
import '../data/sqflite_payment_method_repository.dart';

final paymentMethodRepositoryProvider = Provider<PaymentMethodRepository>((
  ref,
) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) {
    throw StateError('No hay un usuario autenticado.');
  }

  return SqflitePaymentMethodRepository(
    database: ref.watch(appDatabaseProvider),
    userId: userId,
  );
});

class PaymentMethodsNotifier extends AsyncNotifier<List<PaymentMethod>> {
  @override
  Future<List<PaymentMethod>> build() async {
    await ref.watch(ownershipMigrationProvider.future);
    return ref.watch(paymentMethodRepositoryProvider).list();
  }

  Future<PaymentMethod> add({
    required String holderName,
    required PaymentBrand brand,
    required String last4,
    required int expiryMonth,
    required int expiryYear,
    bool isDefault = false,
  }) async {
    final method = await ref
        .read(paymentMethodRepositoryProvider)
        .create(
          holderName: holderName,
          brand: brand,
          last4: last4,
          expiryMonth: expiryMonth,
          expiryYear: expiryYear,
          isDefault: isDefault,
        );
    await _refresh();
    return method;
  }

  Future<void> delete(String id) async {
    await ref.read(paymentMethodRepositoryProvider).delete(id);
    await _refresh();
  }

  Future<void> setDefault(String id) async {
    await ref.read(paymentMethodRepositoryProvider).setDefault(id);
    await _refresh();
  }

  Future<void> _refresh() async {
    final methods = await ref.read(paymentMethodRepositoryProvider).list();
    state = AsyncData(methods);
  }
}

final paymentMethodsProvider =
    AsyncNotifierProvider.autoDispose<
      PaymentMethodsNotifier,
      List<PaymentMethod>
    >(PaymentMethodsNotifier.new, retry: (retryCount, error) => null);
