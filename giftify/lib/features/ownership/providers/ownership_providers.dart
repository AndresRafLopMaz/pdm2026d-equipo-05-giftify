import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/current_user_provider.dart';
import '../data/ownership_migration_service.dart';

final ownershipMigrationServiceProvider = Provider<OwnershipMigrationService>((
  ref,
) {
  return OwnershipMigrationService();
});

final ownershipMigrationProvider = FutureProvider<OwnershipMigrationResult>((
  ref,
) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) {
    return OwnershipMigrationResult.notNeeded;
  }

  return ref.watch(ownershipMigrationServiceProvider).migrateForUser(userId);
});
