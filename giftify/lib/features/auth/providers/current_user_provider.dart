import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_controller.dart';

final currentUserIdProvider = Provider<int?>((ref) {
  return ref.watch(authControllerProvider).value?.id;
});
