/// Configuración reservada para una futura integración con backend.
///
/// Actualmente Giftify funciona principalmente con datos locales.
/// La URL puede proporcionarse posteriormente utilizando:
///
/// flutter run --dart-define=GIFTIFY_API_BASE_URL=https://ejemplo.com
abstract final class BackendConfig {
  static const String baseUrl = String.fromEnvironment(
    'GIFTIFY_API_BASE_URL',
    defaultValue: '',
  );

  /// Indica si se proporcionó una URL de backend.
  static bool get isConfigured => baseUrl.trim().isNotEmpty;
}
