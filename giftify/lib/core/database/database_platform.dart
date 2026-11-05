import 'package:flutter/foundation.dart';

import 'database_platform_stub.dart'
    if (dart.library.js_interop) 'database_platform_web.dart'
    as platform;

void configureDatabasePlatform() {
  if (kIsWeb) {
    platform.configureDatabaseFactory();
  }
}
