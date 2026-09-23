import 'backend_config.dart';

/// Punto de entrada reservado para una futura comunicación con backend.
///
/// Esta clase NO realiza solicitudes HTTP todavía.
/// Su finalidad actual es evitar que cada módulo defina su propia
/// configuración cuando se incorpore una API real.
class BackendClient {
  const BackendClient({this.baseUrl = BackendConfig.baseUrl});

  final String baseUrl;

  bool get isConfigured => baseUrl.trim().isNotEmpty;

  /// Construye una URI relativa al backend configurado.
  ///
  /// No realiza ninguna solicitud de red.
  Uri buildUri(String path, {Map<String, String>? queryParameters}) {
    if (!isConfigured) {
      throw StateError('El backend de Giftify todavía no ha sido configurado.');
    }

    final normalizedBaseUrl = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';

    final normalizedPath = path.startsWith('/') ? path.substring(1) : path;

    return Uri.parse(
      normalizedBaseUrl,
    ).resolve(normalizedPath).replace(queryParameters: queryParameters);
  }
}
