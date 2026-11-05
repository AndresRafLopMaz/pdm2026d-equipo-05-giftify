import 'package:flutter/foundation.dart';

import '../enums/gift_age_range.dart';
import '../enums/gift_format.dart';
import '../enums/gift_interest.dart';
import '../enums/gift_occasion.dart';
import '../enums/gift_recipient.dart';
import '../enums/gift_size.dart';

/// Parámetros proporcionados por el usuario para buscar un regalo.
///
/// Este modelo conecta la pantalla de personalización con la pantalla
/// de resultados. No contiene lógica de interfaz.
@immutable
class GiftSearchCriteria {
  const GiftSearchCriteria({
    required this.recipientType,
    required this.occasion,
    required this.maxBudget,
    this.ageRange,
    this.interests = const {},
    this.giftFormat,
    this.size,
    this.eventDate,
    this.isPersonalizable = false,
    this.isLocal = false,
    this.fastDelivery = false,
    this.onlyAvailable = false,
  });

  final GiftRecipient recipientType;
  final GiftOccasion occasion;

  /// Presupuesto máximo expresado en quetzales.
  final double maxBudget;

  final GiftAgeRange? ageRange;
  final Set<GiftInterest> interests;
  final GiftFormat? giftFormat;
  final GiftSize? size;
  final DateTime? eventDate;

  final bool isPersonalizable;
  final bool isLocal;
  final bool fastDelivery;
  final bool onlyAvailable;

  GiftSearchCriteria copyWith({
    GiftRecipient? recipientType,
    GiftOccasion? occasion,
    double? maxBudget,
    GiftAgeRange? ageRange,
    bool clearAgeRange = false,
    Set<GiftInterest>? interests,
    GiftFormat? giftFormat,
    bool clearGiftFormat = false,
    GiftSize? size,
    bool clearSize = false,
    DateTime? eventDate,
    bool clearEventDate = false,
    bool? isPersonalizable,
    bool? isLocal,
    bool? fastDelivery,
    bool? onlyAvailable,
  }) {
    return GiftSearchCriteria(
      recipientType: recipientType ?? this.recipientType,
      occasion: occasion ?? this.occasion,
      maxBudget: maxBudget ?? this.maxBudget,
      ageRange: clearAgeRange ? null : (ageRange ?? this.ageRange),
      interests: interests ?? this.interests,
      giftFormat: clearGiftFormat ? null : (giftFormat ?? this.giftFormat),
      size: clearSize ? null : (size ?? this.size),
      eventDate: clearEventDate ? null : (eventDate ?? this.eventDate),
      isPersonalizable: isPersonalizable ?? this.isPersonalizable,
      isLocal: isLocal ?? this.isLocal,
      fastDelivery: fastDelivery ?? this.fastDelivery,
      onlyAvailable: onlyAvailable ?? this.onlyAvailable,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is GiftSearchCriteria &&
            other.recipientType == recipientType &&
            other.occasion == occasion &&
            other.maxBudget == maxBudget &&
            other.ageRange == ageRange &&
            setEquals(other.interests, interests) &&
            other.giftFormat == giftFormat &&
            other.size == size &&
            other.eventDate == eventDate &&
            other.isPersonalizable == isPersonalizable &&
            other.isLocal == isLocal &&
            other.fastDelivery == fastDelivery &&
            other.onlyAvailable == onlyAvailable;
  }

  @override
  int get hashCode {
    final interestHash = Object.hashAll(
      interests.map((interest) => interest.index).toList()..sort(),
    );

    return Object.hash(
      recipientType,
      occasion,
      maxBudget,
      ageRange,
      interestHash,
      giftFormat,
      size,
      eventDate,
      isPersonalizable,
      isLocal,
      fastDelivery,
      onlyAvailable,
    );
  }
}
