import 'package:flutter/material.dart';

const Color giftifyPrimary = Color(0xFF5867B8);
const Color giftifyPrimaryContainer = Color(0xFFEEF0FF);
const Color giftifyBackground = Color(0xFFF8F9FC);
const Color giftifySurface = Color(0xFFFFFFFF);
const Color giftifySurfaceMuted = Color(0xFFF2F3F8);
const Color giftifyText = Color(0xFF262936);
const Color giftifyMuted = Color(0xFF697080);
const Color giftifyBorder = Color(0xFFE4E6EC);
const Color giftifyError = Color(0xFFB3261E);
const Color giftifyWarning = Color(0xFF8A5A00);
const Color giftifyWarningBackground = Color(0xFFFFF7EA);

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
    return Theme.of(context).extension<GiftifyColors>() ?? giftifyColors;
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

const ColorScheme _giftifyColorScheme = ColorScheme(
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
  outline: giftifyBorder,
  outlineVariant: giftifyBorder,
  shadow: Colors.black,
  scrim: Colors.black,
  inverseSurface: giftifyText,
  onInverseSurface: Colors.white,
  inversePrimary: Color(0xFFC3CAF4),
  surfaceTint: giftifyPrimary,
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

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  colorScheme: _giftifyColorScheme,
  scaffoldBackgroundColor: giftifyBackground,
  textTheme: _giftifyTextTheme,
  extensions: const <ThemeExtension<dynamic>>[giftifyColors],
  appBarTheme: const AppBarTheme(
    backgroundColor: giftifyBackground,
    foregroundColor: giftifyText,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,
    titleTextStyle: TextStyle(
      color: giftifyText,
      fontSize: 22,
      height: 1.27,
      fontWeight: FontWeight.w700,
    ),
    iconTheme: IconThemeData(color: giftifyText, size: 24),
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
          return giftifySurfaceMuted;
        }
        return giftifyPrimary;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return giftifyMuted;
        }
        return Colors.white;
      }),
      overlayColor: WidgetStatePropertyAll(
        Colors.white.withValues(alpha: 0.12),
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
      foregroundColor: const WidgetStatePropertyAll(giftifyPrimary),
      side: const WidgetStatePropertyAll(BorderSide(color: giftifyBorder)),
      overlayColor: WidgetStatePropertyAll(
        giftifyPrimary.withValues(alpha: 0.08),
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
      foregroundColor: const WidgetStatePropertyAll(giftifyPrimary),
      overlayColor: WidgetStatePropertyAll(
        giftifyPrimary.withValues(alpha: 0.08),
      ),
    ),
  ),
  cardTheme: CardThemeData(
    color: giftifySurface,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    margin: EdgeInsets.zero,
    clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: giftifyBorder),
    ),
  ),
  chipTheme: ChipThemeData(
    backgroundColor: giftifySurface,
    selectedColor: giftifyPrimaryContainer,
    disabledColor: giftifySurfaceMuted,
    labelStyle: const TextStyle(
      color: giftifyText,
      fontSize: 13,
      fontWeight: FontWeight.w500,
    ),
    secondaryLabelStyle: const TextStyle(
      color: giftifyPrimary,
      fontSize: 13,
      fontWeight: FontWeight.w600,
    ),
    side: const BorderSide(color: giftifyBorder),
    shape: const StadiumBorder(),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    showCheckmark: false,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: giftifySurface,
    labelStyle: const TextStyle(
      color: giftifyMuted,
      fontSize: 14,
      height: 1.43,
    ),
    floatingLabelStyle: const TextStyle(
      color: giftifyPrimary,
      fontSize: 14,
      height: 1.43,
      fontWeight: FontWeight.w600,
    ),
    hintStyle: const TextStyle(color: giftifyMuted, fontSize: 14, height: 1.43),
    helperStyle: const TextStyle(
      color: giftifyMuted,
      fontSize: 12,
      height: 1.33,
    ),
    errorStyle: const TextStyle(
      color: giftifyError,
      fontSize: 12,
      height: 1.33,
    ),
    prefixIconColor: giftifyMuted,
    suffixIconColor: giftifyMuted,
    errorMaxLines: 2,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: giftifyBorder),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: giftifyBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: giftifyPrimary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: giftifyError),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: giftifyError, width: 2),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: giftifyBorder),
    ),
  ),
  navigationBarTheme: NavigationBarThemeData(
    height: 70,
    elevation: 0,
    backgroundColor: giftifySurface,
    surfaceTintColor: Colors.transparent,
    indicatorColor: giftifyPrimaryContainer,
    labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    iconTheme: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const IconThemeData(color: giftifyPrimary, size: 24);
      }
      return const IconThemeData(color: giftifyMuted, size: 24);
    }),
    labelTextStyle: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const TextStyle(
          color: giftifyPrimary,
          fontSize: 12,
          height: 1.33,
          fontWeight: FontWeight.w600,
        );
      }
      return const TextStyle(
        color: giftifyMuted,
        fontSize: 12,
        height: 1.33,
        fontWeight: FontWeight.w600,
      );
    }),
  ),
  dividerTheme: const DividerThemeData(
    color: giftifyBorder,
    thickness: 1,
    space: 1,
  ),
  snackBarTheme: SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    backgroundColor: giftifyText,
    contentTextStyle: const TextStyle(
      color: Colors.white,
      fontSize: 14,
      height: 1.43,
    ),
    actionTextColor: giftifyPrimaryContainer,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    insetPadding: const EdgeInsets.all(16),
  ),
  dialogTheme: DialogThemeData(
    backgroundColor: giftifySurface,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    titleTextStyle: const TextStyle(
      color: giftifyText,
      fontSize: 22,
      height: 1.27,
      fontWeight: FontWeight.w700,
    ),
    contentTextStyle: const TextStyle(
      color: giftifyMuted,
      fontSize: 14,
      height: 1.5,
    ),
  ),
);
