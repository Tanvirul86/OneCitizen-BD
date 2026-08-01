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
    this.applicationFields = const [],
    this.disbursementAmount = 0,
  });

  final String id;
  final CardTypeCode code;
  final String name;
  final String eligibilityCriteria;
  final List<String> requiredDocuments;
  final List<CardTypeApplicationField> applicationFields;

  /// Fixed per-citizen amount (BDT) used when disbursing funds to every
  /// approved holder of this card type at once.
  final double disbursementAmount;

  factory CardType.fromJson(Map<String, dynamic> json) {
    return CardType(
      id: json['id']?.toString() ?? '',
      code: cardTypeCodeFromString(json['code'] as String?),
      name: json['name'] as String? ?? '',
      eligibilityCriteria: json['eligibility_criteria'] as String? ?? '',
      disbursementAmount:
          (json['disbursement_amount'] as num?)?.toDouble() ?? 0,
      requiredDocuments:
          (json['required_documents'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      applicationFields:
          (json['application_fields'] as List<dynamic>?)
              ?.whereType<Map>()
              .map(
                (field) => CardTypeApplicationField.fromJson(
                  field.cast<String, dynamic>(),
                ),
              )
              .toList() ??
          [],
    );
  }
}

/// Field definitions are owned by the backend card-type configuration.
class CardTypeApplicationField {
  const CardTypeApplicationField({
    required this.key,
    required this.label,
    required this.required,
    this.hintText,
    this.inputType,
    this.options = const [],
  });

  final String key;
  final String label;
  final bool required;
  final String? hintText;
  final String? inputType;
  final List<String> options;

  factory CardTypeApplicationField.fromJson(Map<String, dynamic> json) {
    return CardTypeApplicationField(
      key: json['key']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      required: json['required'] as bool? ?? false,
      hintText: json['hint']?.toString(),
      inputType: json['input_type']?.toString(),
      options:
          (json['options'] as List<dynamic>?)
              ?.map((option) => option.toString())
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
      results:
          (json['results'] as List<dynamic>?)
              ?.map((e) => CardEligibility.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  List<CardEligibility> get eligibleCards =>
      results.where((r) => r.eligible).toList();
}
