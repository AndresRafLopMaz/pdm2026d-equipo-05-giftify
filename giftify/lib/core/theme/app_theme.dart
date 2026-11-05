import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const Color giftifyPrimary = Color(0xFF5867B8);
const Color giftifyPrimaryContainer = Color(0xFFEEF0FF);
const Color giftifyBackground = Color(0xFFF8F9FC);
const Color giftifySurface = Color(0xFFFFFFFF);
const Color giftifySurfaceMuted = Color(0xFFF2F3F8);
const Color giftifyText = Color(0xFF262936);
const Color giftifyMuted = Color(0xFF5F6777);
const Color giftifyBorder = Color(0xFFE4E6EC);
const Color giftifyOutline = Color(0xFF878E9F);
const Color giftifyError = Color(0xFFB3261E);

const Color giftifyDarkBackground = Color(0xFF121318);
const Color giftifyDarkSurface = Color(0xFF1A1B22);
const Color giftifyDarkSurfaceMuted = Color(0xFF23252E);
const Color giftifyDarkBorder = Color(0xFF343742);
const Color giftifyDarkOutline = Color(0xFF6B7284);
const Color giftifyDarkText = Color(0xFFF3F4F7);
const Color giftifyDarkMuted = Color(0xFFAEB3C2);

@immutable
class GiftifyColors extends ThemeExtension<GiftifyColors> {
  const GiftifyColors({
    required this.secondaryStrong,
    required this.secondarySoft,
    required this.blush,
    required this.blushStrong,
    required this.blushSoft,
    required this.warm,
    required this.warmStrong,
    required this.warmSoft,
    required this.success,
    required this.successStrong,
    required this.successSoft,
  });

  final Color secondaryStrong;
  final Color secondarySoft;
  final Color blush;
  final Color blushStrong;
  final Color blushSoft;
  final Color warm;
  final Color warmStrong;
  final Color warmSoft;
  final Color success;
  final Color successStrong;
  final Color successSoft;

  static GiftifyColors of(BuildContext context) {
    final theme = Theme.of(context);
    final extension = theme.extension<GiftifyColors>();
    if (extension != null) {
      return extension;
    }

    return theme.brightness == Brightness.dark
        ? giftifyColorsDark
        : giftifyColors;
  }

  @override
  GiftifyColors copyWith({
    Color? secondaryStrong,
    Color? secondarySoft,
    Color? blush,
    Color? blushStrong,
    Color? blushSoft,
    Color? warm,
    Color? warmStrong,
    Color? warmSoft,
    Color? success,
    Color? successStrong,
    Color? successSoft,
  }) {
    return GiftifyColors(
      secondaryStrong: secondaryStrong ?? this.secondaryStrong,
      secondarySoft: secondarySoft ?? this.secondarySoft,
      blush: blush ?? this.blush,
      blushStrong: blushStrong ?? this.blushStrong,
      blushSoft: blushSoft ?? this.blushSoft,
      warm: warm ?? this.warm,
      warmStrong: warmStrong ?? this.warmStrong,
      warmSoft: warmSoft ?? this.warmSoft,
      success: success ?? this.success,
      successStrong: successStrong ?? this.successStrong,
      successSoft: successSoft ?? this.successSoft,
    );
  }

  @override
  GiftifyColors lerp(ThemeExtension<GiftifyColors>? other, double t) {
    if (other is! GiftifyColors) {
      return this;
    }

    return GiftifyColors(
      secondaryStrong: Color.lerp(secondaryStrong, other.secondaryStrong, t)!,
      secondarySoft: Color.lerp(secondarySoft, other.secondarySoft, t)!,
      blush: Color.lerp(blush, other.blush, t)!,
      blushStrong: Color.lerp(blushStrong, other.blushStrong, t)!,
      blushSoft: Color.lerp(blushSoft, other.blushSoft, t)!,
      warm: Color.lerp(warm, other.warm, t)!,
      warmStrong: Color.lerp(warmStrong, other.warmStrong, t)!,
      warmSoft: Color.lerp(warmSoft, other.warmSoft, t)!,
      success: Color.lerp(success, other.success, t)!,
      successStrong: Color.lerp(successStrong, other.successStrong, t)!,
      successSoft: Color.lerp(successSoft, other.successSoft, t)!,
    );
  }
}

const GiftifyColors giftifyColors = GiftifyColors(
  secondaryStrong: Color(0xFF6B5AA6),
  secondarySoft: Color(0xFFF3EFFF),
  blush: Color(0xFFE9B8D0),
  blushStrong: Color(0xFF9B4F73),
  blushSoft: Color(0xFFFFF1F7),
  warm: Color(0xFFF3D6A4),
  warmStrong: Color(0xFF8A5A00),
  warmSoft: Color(0xFFFFF7EA),
  success: Color(0xFF2E7D5B),
  successStrong: Color(0xFF1F6B43),
  successSoft: Color(0xFFE7F5ED),
);

const GiftifyColors giftifyColorsDark = GiftifyColors(
  secondaryStrong: Color(0xFFD4C7FF),
  secondarySoft: Color(0xFF2D2742),
  blush: Color(0xFFD39AB7),
  blushStrong: Color(0xFFFFC0DA),
  blushSoft: Color(0xFF3A2230),
  warm: Color(0xFFF3D6A4),
  warmStrong: Color(0xFFF7D58A),
  warmSoft: Color(0xFF3A2E1B),
  success: Color(0xFF6FCFA2),
  successStrong: Color(0xFF8FE3B8),
  successSoft: Color(0xFF1C3528),
);

const ColorScheme _lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: giftifyPrimary,
  onPrimary: Colors.white,
  primaryContainer: giftifyPrimaryContainer,
  onPrimaryContainer: giftifyText,
  secondary: Color(0xFF9B8BD4),
  onSecondary: giftifyText,
  secondaryContainer: Color(0xFFF3EFFF),
  onSecondaryContainer: Color(0xFF6B5AA6),
  tertiary: Color(0xFF9B4F73),
  onTertiary: Colors.white,
  tertiaryContainer: Color(0xFFFFF1F7),
  onTertiaryContainer: giftifyText,
  error: giftifyError,
  onError: Colors.white,
  errorContainer: Color(0xFFFDECEA),
  onErrorContainer: giftifyError,
  surface: giftifySurface,
  onSurface: giftifyText,
  onSurfaceVariant: giftifyMuted,
  surfaceContainerLowest: giftifySurface,
  surfaceContainerLow: Color(0xFFFCFCFE),
  surfaceContainer: giftifySurfaceMuted,
  surfaceContainerHigh: Color(0xFFEAECF3),
  surfaceContainerHighest: Color(0xFFE2E5EE),
  outline: giftifyOutline,
  outlineVariant: giftifyBorder,
  shadow: Colors.black,
  scrim: Colors.black,
  inverseSurface: giftifyText,
  onInverseSurface: Colors.white,
  inversePrimary: Color(0xFFC3CAF4),
  surfaceTint: giftifyPrimary,
);

const ColorScheme _darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFFAEB9FF),
  onPrimary: Color(0xFF171B30),
  primaryContainer: Color(0xFF2C3352),
  onPrimaryContainer: Color(0xFFE3E7FF),
  secondary: Color(0xFFCFC1FF),
  onSecondary: Color(0xFF241B3A),
  secondaryContainer: Color(0xFF3A2F58),
  onSecondaryContainer: Color(0xFFF0E8FF),
  tertiary: Color(0xFFF0A9C9),
  onTertiary: Color(0xFF3B1728),
  tertiaryContainer: Color(0xFF4A2A3B),
  onTertiaryContainer: Color(0xFFFFD9E8),
  error: Color(0xFFFFB4AB),
  onError: Color(0xFF690005),
  errorContainer: Color(0xFF5C1A16),
  onErrorContainer: Color(0xFFFFDAD6),
  surface: giftifyDarkSurface,
  onSurface: giftifyDarkText,
  onSurfaceVariant: giftifyDarkMuted,
  surfaceContainerLowest: Color(0xFF101116),
  surfaceContainerLow: Color(0xFF171820),
  surfaceContainer: giftifyDarkSurfaceMuted,
  surfaceContainerHigh: Color(0xFF2B2D38),
  surfaceContainerHighest: Color(0xFF323542),
  outline: giftifyDarkOutline,
  outlineVariant: giftifyDarkBorder,
  shadow: Colors.black,
  scrim: Colors.black,
  inverseSurface: giftifyDarkText,
  onInverseSurface: giftifyDarkSurface,
  inversePrimary: giftifyPrimary,
  surfaceTint: Color(0xFFAEB9FF),
);

const TextTheme _giftifyTextTheme = TextTheme(
  displaySmall: TextStyle(
    fontSize: 28,
    height: 1.21,
    fontWeight: FontWeight.w700,
  ),
  headlineSmall: TextStyle(
    fontSize: 22,
    height: 1.27,
    fontWeight: FontWeight.w700,
  ),
  titleLarge: TextStyle(
    fontSize: 22,
    height: 1.27,
    fontWeight: FontWeight.w600,
  ),
  titleMedium: TextStyle(
    fontSize: 18,
    height: 1.33,
    fontWeight: FontWeight.w600,
  ),
  bodyLarge: TextStyle(fontSize: 16, height: 1.5),
  bodyMedium: TextStyle(fontSize: 14, height: 1.43),
  labelLarge: TextStyle(
    fontSize: 14,
    height: 1.43,
    fontWeight: FontWeight.w600,
  ),
  labelMedium: TextStyle(
    fontSize: 12,
    height: 1.33,
    fontWeight: FontWeight.w600,
  ),
);

abstract final class AppTheme {
  static final ThemeData lightTheme = _build(
    scheme: _lightColorScheme,
    giftify: giftifyColors,
    background: giftifyBackground,
    isDark: false,
  );

  static final ThemeData darkTheme = _build(
    scheme: _darkColorScheme,
    giftify: giftifyColorsDark,
    background: giftifyDarkBackground,
    isDark: true,
  );

  static ThemeData _build({
    required ColorScheme scheme,
    required GiftifyColors giftify,
    required Color background,
    required bool isDark,
  }) {
    final snackBackground = isDark
        ? scheme.surfaceContainerHighest
        : scheme.inverseSurface;
    final snackForeground = isDark ? scheme.onSurface : scheme.onInverseSurface;
    final snackAction = isDark ? scheme.primary : scheme.inversePrimary;
    final overlayBase = isDark
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: scheme.brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      textTheme: _giftifyTextTheme,
      extensions: <ThemeExtension<dynamic>>[giftify],
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: overlayBase.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: background,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          systemNavigationBarIconBrightness: isDark
              ? Brightness.light
              : Brightness.dark,
        ),
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 22,
          height: 1.27,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: scheme.onSurface, size: 24),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(64, 52)),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          textStyle: const WidgetStatePropertyAll(
            TextStyle(fontSize: 16, height: 1.25, fontWeight: FontWeight.w600),
          ),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return scheme.surfaceContainerHighest;
            }
            return scheme.primary;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return scheme.onSurfaceVariant;
            }
            return scheme.onPrimary;
          }),
          overlayColor: WidgetStatePropertyAll(
            scheme.onPrimary.withValues(alpha: 0.12),
          ),
          elevation: const WidgetStatePropertyAll(0),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(64, 48)),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          textStyle: const WidgetStatePropertyAll(
            TextStyle(fontSize: 14, height: 1.43, fontWeight: FontWeight.w600),
          ),
          foregroundColor: WidgetStatePropertyAll(scheme.primary),
          side: WidgetStatePropertyAll(BorderSide(color: scheme.outline)),
          overlayColor: WidgetStatePropertyAll(
            scheme.primary.withValues(alpha: 0.08),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          textStyle: const WidgetStatePropertyAll(
            TextStyle(fontSize: 14, height: 1.43, fontWeight: FontWeight.w600),
          ),
          foregroundColor: WidgetStatePropertyAll(scheme.primary),
          overlayColor: WidgetStatePropertyAll(
            scheme.primary.withValues(alpha: 0.08),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surface,
        selectedColor: scheme.primaryContainer,
        disabledColor: scheme.surfaceContainerHighest,
        labelStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        secondaryLabelStyle: TextStyle(
          color: scheme.primary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        side: BorderSide(color: scheme.outlineVariant),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        showCheckmark: true,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        labelStyle: TextStyle(
          color: scheme.onSurfaceVariant,
          fontSize: 14,
          height: 1.43,
        ),
        floatingLabelStyle: TextStyle(
          color: scheme.primary,
          fontSize: 14,
          height: 1.43,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: TextStyle(
          color: scheme.onSurfaceVariant,
          fontSize: 14,
          height: 1.43,
        ),
        helperStyle: TextStyle(
          color: scheme.onSurfaceVariant,
          fontSize: 12,
          height: 1.33,
        ),
        errorStyle: TextStyle(color: scheme.error, fontSize: 12, height: 1.33),
        prefixIconColor: scheme.onSurfaceVariant,
        suffixIconColor: scheme.onSurfaceVariant,
        errorMaxLines: 2,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.error, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 70,
        elevation: 0,
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.primaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: scheme.primary, size: 24);
          }
          return IconThemeData(color: scheme.onSurfaceVariant, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              color: scheme.primary,
              fontSize: 12,
              height: 1.33,
              fontWeight: FontWeight.w600,
            );
          }
          return TextStyle(
            color: scheme.onSurfaceVariant,
            fontSize: 12,
            height: 1.33,
            fontWeight: FontWeight.w600,
          );
        }),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: snackBackground,
        contentTextStyle: TextStyle(
          color: snackForeground,
          fontSize: 14,
          height: 1.43,
        ),
        actionTextColor: snackAction,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        insetPadding: const EdgeInsets.all(16),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 22,
          height: 1.27,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: TextStyle(
          color: scheme.onSurfaceVariant,
          fontSize: 14,
          height: 1.5,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        modalBackgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        modalBarrierColor: scheme.scrim.withValues(alpha: 0.5),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        textStyle: TextStyle(color: scheme.onSurface),
      ),
    );
  }
}

final ThemeData appTheme = AppTheme.lightTheme;
