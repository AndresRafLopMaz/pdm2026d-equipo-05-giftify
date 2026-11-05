import 'package:flutter_riverpod/misc.dart';
import 'package:giftify/features/ownership/data/ownership_migration_service.dart';
import 'package:giftify/features/ownership/providers/ownership_providers.dart';

final Override ownershipNotNeededOverride = ownershipMigrationProvider
    .overrideWith((ref) async => OwnershipMigrationResult.notNeeded);
