/// Criterios ingresados por el usuario para encontrar un regalo.
///
/// Este modelo conecta principalmente la pantalla de personalización
/// con la pantalla de resultados.
class GiftSearchCriteria {
  const GiftSearchCriteria({
    required this.occasion,
    required this.recipient,
    required this.maxBudget,
    this.eventDate,
    this.giftType,
    this.size,
  });

  /// Ocasión del regalo: cumpleaños, aniversario, graduación, etc.
  final String occasion;

  /// Persona o relación con el destinatario.
  final String recipient;

  /// Presupuesto máximo expresado en quetzales.
  final double maxBudget;

  /// Fecha prevista para entregar el regalo.
  final DateTime? eventDate;

  /// Categoría opcional del regalo.
  final String? giftType;

  /// Restricción opcional de tamaño.
  final String? size;
}
