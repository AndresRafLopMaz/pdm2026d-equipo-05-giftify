import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_router.dart';
import '../../auth/providers/auth_controller.dart';
import '../../settings/providers/theme_controller.dart';
import '../widgets/user_avatar.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final user = ref.watch(authControllerProvider).value;
    final themeMode = ref.watch(themeControllerProvider);

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Perfil')),
        body: const Center(child: Text('Sesión no disponible.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          UserAvatar(name: user.name, radius: 36),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.name.trim().isEmpty
                                      ? 'Usuario'
                                      : user.name,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: colors.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user.email,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const _SectionTitle('Cuenta'),
                  const SizedBox(height: 8),
                  Card(
                    child: ListTile(
                      key: const ValueKey('profile-addresses'),
                      leading: const Icon(Icons.location_on_outlined),
                      title: const Text('Mis direcciones'),
                      subtitle: const Text(
                        'Gestiona tus direcciones de entrega.',
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.addresses);
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  const _SectionTitle('Preferencias'),
                  const SizedBox(height: 8),
                  Card(
                    child: ListTile(
                      key: const ValueKey('profile-settings'),
                      leading: const Icon(Icons.palette_outlined),
                      title: const Text('Apariencia'),
                      subtitle: Text(_themeModeLabel(themeMode)),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.settings);
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  const _SectionTitle('Sesión'),
                  const SizedBox(height: 8),
                  Card(
                    child: ListTile(
                      key: const ValueKey('profile-logout-button'),
                      leading: Icon(Icons.logout_rounded, color: colors.error),
                      title: Text(
                        'Cerrar sesión',
                        style: TextStyle(color: colors.error),
                      ),
                      onTap: () => _logout(context, ref),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(authControllerProvider.notifier).logout();
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      final messenger = ScaffoldMessenger.of(context);
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('No pudimos cerrar la sesión. Intenta nuevamente.'),
        ),
      );
    }
  }

  String _themeModeLabel(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.system => 'Sistema',
      ThemeMode.light => 'Claro',
      ThemeMode.dark => 'Oscuro',
    };
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
