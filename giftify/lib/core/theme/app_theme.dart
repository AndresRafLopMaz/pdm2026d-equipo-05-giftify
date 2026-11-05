import 'package:flutter/material.dart';

const Color verdePrincipal = Color(0xFF18B870);
const Color verdeOscuro = Color(0xFF087A4A);
const Color verdeClaro = Color(0xFFE9F8F1);

const Color rosaPrincipal = Color(0xFFF05CB5);
const Color rosaClaro = Color(0xFFFFE9F6);

const Color amarilloPrincipal = Color(0xFFFFD56A);

const Color fondoPrincipal = Color(0xFFF8FAF9);
const Color textoPrincipal = Color(0xFF252A28);
const Color textoSecundario = Color(0xFF777D7A);

const Color giftifyPrimary = Color(0xFF087A4A);
const Color giftifyPrimaryContainer = Color(0xFFE6F4EC);
const Color giftifyBackground = Color(0xFFF7F8F7);
const Color giftifySurface = Color(0xFFFFFFFF);
const Color giftifySurfaceMuted = Color(0xFFEEF2EF);
const Color giftifyText = Color(0xFF1F2522);
const Color giftifyMuted = Color(0xFF5F6B64);
const Color giftifyBorder = Color(0xFFD8E0DB);
const Color giftifyError = Color(0xFFB3261E);
const Color giftifyWarning = Color(0xFF7A5200);
const Color giftifyWarningBackground = Color(0xFFFFF4D6);

const ColorScheme _giftifyColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: giftifyPrimary,
  onPrimary: Colors.white,
  primaryContainer: giftifyPrimaryContainer,
  onPrimaryContainer: giftifyText,
  secondary: giftifyPrimary,
  onSecondary: Colors.white,
  secondaryContainer: giftifyPrimaryContainer,
  onSecondaryContainer: giftifyText,
  tertiary: giftifyMuted,
  onTertiary: Colors.white,
  tertiaryContainer: giftifySurfaceMuted,
  onTertiaryContainer: giftifyText,
  error: giftifyError,
  onError: Colors.white,
  errorContainer: Color(0xFFFDECEA),
  onErrorContainer: giftifyError,
  surface: giftifySurface,
  onSurface: giftifyText,
  onSurfaceVariant: giftifyMuted,
  surfaceContainerLowest: giftifySurface,
  surfaceContainerLow: Color(0xFFFBFCFB),
  surfaceContainer: giftifySurfaceMuted,
  surfaceContainerHigh: Color(0xFFE8EEEA),
  surfaceContainerHighest: Color(0xFFE1E8E3),
  outline: giftifyBorder,
  outlineVariant: giftifyBorder,
  shadow: Colors.black,
  scrim: Colors.black,
  inverseSurface: giftifyText,
  onInverseSurface: Colors.white,
  inversePrimary: giftifyPrimaryContainer,
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
    height: 64,
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
