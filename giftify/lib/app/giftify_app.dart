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
      initialRoute: AppRoutes.register,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
