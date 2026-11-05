import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:giftify/core/theme/app_theme.dart';

double _contrastRatio(Color foreground, Color background) {
  final first = foreground.computeLuminance();
  final second = background.computeLuminance();
  final lighter = first > second ? first : second;
  final darker = first > second ? second : first;
  return (lighter + 0.05) / (darker + 0.05);
}

void expectContrast(
  Color foreground,
  Color background, {
  double minimum = 4.5,
}) {
  expect(_contrastRatio(foreground, background), greaterThanOrEqualTo(minimum));
}

void main() {
  test('los tokens críticos light cumplen contraste AA', () {
    final scheme = AppTheme.lightTheme.colorScheme;
    final giftify = AppTheme.lightTheme.extension<GiftifyColors>()!;

    expectContrast(giftifyPrimary, Colors.white);
    expectContrast(giftifyMuted, giftifyBackground);
    expectContrast(giftifyPrimary, giftifyPrimaryContainer);
    expectContrast(giftify.successStrong, giftify.successSoft);
    expectContrast(giftify.warmStrong, giftify.warmSoft);
    expectContrast(giftify.blushStrong, giftify.blushSoft);
    expectContrast(giftify.secondaryStrong, giftify.secondarySoft);
    expectContrast(giftifyText, giftifyBackground);
    expectContrast(scheme.error, scheme.errorContainer);
    expectContrast(scheme.onError, scheme.error);
  });

  test('los tokens críticos dark cumplen contraste AA', () {
    final theme = AppTheme.darkTheme;
    final scheme = theme.colorScheme;
    final giftify = theme.extension<GiftifyColors>()!;

    expectContrast(scheme.onSurface, scheme.surface);
    expectContrast(scheme.onSurface, theme.scaffoldBackgroundColor);
    expectContrast(scheme.onSurfaceVariant, scheme.surface);
    expectContrast(scheme.onSurfaceVariant, scheme.surfaceContainerHighest);
    expectContrast(scheme.primary, scheme.surface);
    expectContrast(scheme.primary, scheme.primaryContainer);
    expectContrast(scheme.onPrimary, scheme.primary);
    expectContrast(scheme.onPrimaryContainer, scheme.primaryContainer);
    expectContrast(giftify.secondaryStrong, giftify.secondarySoft);
    expectContrast(giftify.blushStrong, giftify.blushSoft);
    expectContrast(giftify.warmStrong, giftify.warmSoft);
    expectContrast(giftify.successStrong, giftify.successSoft);
    expectContrast(scheme.error, scheme.errorContainer);
    expectContrast(scheme.onError, scheme.error);
    expectContrast(scheme.onErrorContainer, scheme.errorContainer);
  });
}
