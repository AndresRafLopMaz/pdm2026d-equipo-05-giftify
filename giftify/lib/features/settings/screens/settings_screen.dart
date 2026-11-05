import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/theme_preference_store.dart';
import '../providers/theme_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final mode = ref.watch(themeControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Apariencia',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Elige cómo se ve Giftify en este dispositivo.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: RadioGroup<ThemeMode>(
                      groupValue: mode,
                      onChanged: (value) async {
                        if (value != null) {
                          await _setMode(context, ref, value);
                        }
                      },
                      child: const Column(
                        children: [
                          RadioListTile<ThemeMode>(
                            key: ValueKey('theme-option-system'),
                            value: ThemeMode.system,
                            title: Text('Sistema'),
                            subtitle: Text(
                              'Sigue la apariencia del dispositivo.',
                            ),
                          ),
                          Divider(height: 1),
                          RadioListTile<ThemeMode>(
                            key: ValueKey('theme-option-light'),
                            value: ThemeMode.light,
                            title: Text('Claro'),
                            subtitle: Text('Usa siempre el tema claro.'),
                          ),
                          Divider(height: 1),
                          RadioListTile<ThemeMode>(
                            key: ValueKey('theme-option-dark'),
                            value: ThemeMode.dark,
                            title: Text('Oscuro'),
                            subtitle: Text('Usa siempre el tema oscuro.'),
                          ),
                        ],
                      ),
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

  Future<void> _setMode(
    BuildContext context,
    WidgetRef ref,
    ThemeMode mode,
  ) async {
    try {
      await ref.read(themeControllerProvider.notifier).setMode(mode);
    } on ThemePersistenceException {
      if (context.mounted) {
        _showError(context);
      }
    } catch (_) {
      if (context.mounted) {
        _showError(context);
      }
    }
  }

  void _showError(BuildContext context) {
    if (!context.mounted) {
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      const SnackBar(
        content: Text('No pudimos guardar tu preferencia de apariencia.'),
      ),
    );
  }
}
