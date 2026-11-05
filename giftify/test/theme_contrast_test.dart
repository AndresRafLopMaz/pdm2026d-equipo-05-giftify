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

void main() {
  test('los tokens críticos cumplen contraste AA', () {
    final giftify = appTheme.extension<GiftifyColors>()!;

    expect(
      _contrastRatio(giftifyPrimary, Colors.white),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      _contrastRatio(giftifyMuted, giftifyBackground),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      _contrastRatio(giftifyPrimary, giftifyPrimaryContainer),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      _contrastRatio(giftify.successStrong, giftify.successSoft),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      _contrastRatio(giftify.warmStrong, giftify.warmSoft),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      _contrastRatio(giftify.blushStrong, giftify.blushSoft),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      _contrastRatio(giftify.secondaryStrong, giftify.secondarySoft),
      greaterThanOrEqualTo(4.5),
    );
  });
}
