import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../features/auth/providers/auth_controller.dart';
import '../features/cart/providers/cart_filter_provider.dart';
import '../features/products/providers/product_filter_provider.dart';
import '../features/search/providers/search_prefill_provider.dart';
import '../features/settings/providers/theme_controller.dart';
import 'app_router.dart';
import 'app_tab.dart';
import 'app_tab_notifier.dart';

class GiftifyApp extends ConsumerStatefulWidget {
  const GiftifyApp({super.key});

  @override
  ConsumerState<GiftifyApp> createState() => _GiftifyAppState();
}

class _GiftifyAppState extends ConsumerState<GiftifyApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeControllerProvider);

    ref.listen(authControllerProvider, (previous, next) {
      final wasAuthenticated = previous?.value != null;
      final isUnauthenticated = next.value == null && !next.isLoading;
      if (!wasAuthenticated || !isUnauthenticated) {
        return;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(appTabProvider.notifier).select(AppTab.home);
        ref.read(productFilterProvider.notifier).clear();
        ref.read(cartFilterProvider.notifier).clear();
        ref.read(searchPrefillProvider.notifier).clear();
        _navigatorKey.currentState?.popUntil((route) => route.isFirst);
      });
    });

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Giftify',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      navigatorKey: _navigatorKey,
      initialRoute: AppRoutes.root,
      onGenerateRoute: AppRouter.onGenerateRoute,
      builder: (context, child) {
        final theme = Theme.of(context);
        final brightness = theme.brightness;
        final overlay =
            (brightness == Brightness.dark
                    ? SystemUiOverlayStyle.light
                    : SystemUiOverlayStyle.dark)
                .copyWith(
                  statusBarColor: Colors.transparent,
                  systemNavigationBarColor: theme.scaffoldBackgroundColor,
                  statusBarIconBrightness: brightness,
                  systemNavigationBarIconBrightness: brightness,
                );

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: overlay,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
