/// Parámetros proporcionados por el usuario para buscar un regalo.
///
/// Este modelo conecta la pantalla de personalización con la pantalla
/// de resultados. No contiene lógica de interfaz.
class GiftSearchCriteria {
  const GiftSearchCriteria({
    required this.occasion,
    required this.recipient,
    required this.maxBudget,
    this.eventDate,
    this.giftType,
    this.size,
  });

  /// Ocasión: cumpleaños, aniversario, graduación, etc.
  final String occasion;

  /// Persona o relación con quien recibirá el regalo.
  final String recipient;

  /// Presupuesto máximo expresado en quetzales.
  final double maxBudget;

  /// Fecha prevista para entregar el regalo.
  final DateTime? eventDate;

  /// Categoría opcional seleccionada por el usuario.
  final String? giftType;

  /// Tamaño opcional del regalo.
  final String? size;

  /// Crea una copia modificando únicamente los valores indicados.
  GiftSearchCriteria copyWith({
    String? occasion,
    String? recipient,
    double? maxBudget,
    DateTime? eventDate,
    String? giftType,
    String? size,
  }) {
    return GiftSearchCriteria(
      occasion: occasion ?? this.occasion,
      recipient: recipient ?? this.recipient,
      maxBudget: maxBudget ?? this.maxBudget,
      eventDate: eventDate ?? this.eventDate,
      giftType: giftType ?? this.giftType,
      size: size ?? this.size,
    );
  }
}
