enum CardTypeCode { farmer, family, education }

CardTypeCode cardTypeCodeFromString(String? value) {
  switch (value?.toLowerCase()) {
    case 'family':
      return CardTypeCode.family;
    case 'education':
      return CardTypeCode.education;
    default:
      return CardTypeCode.farmer;
  }
}

String cardTypeCodeToString(CardTypeCode code) {
  switch (code) {
    case CardTypeCode.farmer:
      return 'farmer';
    case CardTypeCode.family:
      return 'family';
    case CardTypeCode.education:
      return 'education';
  }
}

class CardType {
  const CardType({
    required this.id,
    required this.code,
    required this.name,
    required this.eligibilityCriteria,
    this.requiredDocuments = const [],
  });

  final String id;
  final CardTypeCode code;
  final String name;
  final String eligibilityCriteria;
  final List<String> requiredDocuments;

  factory CardType.fromJson(Map<String, dynamic> json) {
    return CardType(
      id: json['id']?.toString() ?? '',
      code: cardTypeCodeFromString(json['code'] as String?),
      name: json['name'] as String? ?? '',
      eligibilityCriteria: json['eligibility_criteria'] as String? ?? '',
      requiredDocuments: (json['required_documents'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}

/// Per-card-type eligibility verdict, returned together for all three cards.
class CardEligibility {
  const CardEligibility({
    required this.cardType,
    required this.eligible,
    required this.reason,
  });

  final CardType cardType;
  final bool eligible;
  final String reason;

  factory CardEligibility.fromJson(Map<String, dynamic> json) {
    return CardEligibility(
      cardType: CardType.fromJson(json['card_type'] as Map<String, dynamic>),
      eligible: json['eligible'] as bool? ?? false,
      reason: json['reason'] as String? ?? '',
    );
  }
}

class EligibilityResult {
  const EligibilityResult({required this.results});

  final List<CardEligibility> results;

  factory EligibilityResult.fromJson(Map<String, dynamic> json) {
    return EligibilityResult(
      results: (json['results'] as List<dynamic>?)
              ?.map((e) => CardEligibility.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  List<CardEligibility> get eligibleCards =>
      results.where((r) => r.eligible).toList();
}
