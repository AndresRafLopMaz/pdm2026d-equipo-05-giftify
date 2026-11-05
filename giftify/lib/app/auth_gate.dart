import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/providers/auth_controller.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import 'main_shell.dart';

enum AuthView { login, register }

class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key, this.initialView = AuthView.login});

  final AuthView initialView;

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  late AuthView _view;

  @override
  void initState() {
    super.initState();
    _view = widget.initialView;
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);

    ref.listen(authControllerProvider, (previous, next) {
      final wasAuthenticated = previous?.value != null;
      final isUnauthenticated = next.value == null && !next.isLoading;
      if (wasAuthenticated && isUnauthenticated && _view != AuthView.login) {
        setState(() {
          _view = AuthView.login;
        });
      }
    });

    return auth.when(
      loading: () => const _AuthLoadingScreen(),
      error: (_, _) => _AuthErrorScreen(
        onRetry: () => ref.invalidate(authControllerProvider),
      ),
      data: (user) {
        if (user != null) {
          return const MainShell();
        }

        return _AuthFlow(
          view: _view,
          onLogin: () {
            setState(() {
              _view = AuthView.login;
            });
          },
          onRegister: () {
            setState(() {
              _view = AuthView.register;
            });
          },
        );
      },
    );
  }
}

class _AuthFlow extends StatelessWidget {
  const _AuthFlow({
    required this.view,
    required this.onLogin,
    required this.onRegister,
  });

  final AuthView view;
  final VoidCallback onLogin;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    return switch (view) {
      AuthView.login => LoginScreen(onCreateAccount: onRegister),
      AuthView.register => RegisterScreen(onLogin: onLogin),
    };
  }
}

class _AuthLoadingScreen extends StatelessWidget {
  const _AuthLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: CircularProgressIndicator(
            key: ValueKey('auth-loading-indicator'),
          ),
        ),
      ),
    );
  }
}

class _AuthErrorScreen extends StatelessWidget {
  const _AuthErrorScreen({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock_reset_rounded,
                    size: 48,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No pudimos restaurar tu sesión.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Intenta nuevamente para continuar.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    key: const ValueKey('auth-retry-button'),
                    onPressed: onRetry,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
