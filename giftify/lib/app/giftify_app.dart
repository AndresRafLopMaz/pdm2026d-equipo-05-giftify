import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import 'app_router.dart';

class GiftifyApp extends StatelessWidget {
  const GiftifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Giftify',
      theme: appTheme,

      // Temporalmente iniciamos en Home para conservar
      // el comportamiento de la versión actual.
      // Cuando el flujo de autenticación esté terminado,
      // esta decisión se actualizará.
      initialRoute: AppRoutes.home,

      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
