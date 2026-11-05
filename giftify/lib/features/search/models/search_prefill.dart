import '../../../shared/enums/gift_format.dart';
import '../../../shared/enums/gift_interest.dart';
import '../../../shared/enums/gift_occasion.dart';
import '../../../shared/enums/gift_recipient.dart';

class SearchPrefill {
  const SearchPrefill({
    this.recipientType,
    this.occasion,
    this.interests = const {},
    this.giftFormat,
  });

  final GiftRecipient? recipientType;
  final GiftOccasion? occasion;
  final Set<GiftInterest> interests;
  final GiftFormat? giftFormat;
}
