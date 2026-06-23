class CardType {
  const CardType({
    required this.id,
    required this.name,
    required this.code,
    this.description,
    this.isActive = true,
    this.requiredDocuments = const [],
    this.eligibilityRules = const {},
  });

  final String id;
  final String name;
  final String code;
  final String? description;
  final bool isActive;
  final List<String> requiredDocuments;
  final Map<String, dynamic> eligibilityRules;

  factory CardType.fromJson(Map<String, dynamic> json) {
    return CardType(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      description: json['description'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      requiredDocuments: (json['required_documents'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      eligibilityRules:
          (json['eligibility_rules'] as Map<String, dynamic>?) ?? {},
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'code': code,
        'description': description,
        'is_active': isActive,
        'required_documents': requiredDocuments,
        'eligibility_rules': eligibilityRules,
      };
}

class EligibilityResult {
  const EligibilityResult({
    required this.eligibleCards,
    this.recommendations = const [],
    this.message,
  });

  final List<CardType> eligibleCards;
  final List<String> recommendations;
  final String? message;

  factory EligibilityResult.fromJson(Map<String, dynamic> json) {
    return EligibilityResult(
      eligibleCards: (json['eligible_cards'] as List<dynamic>?)
              ?.map((e) => CardType.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      recommendations: (json['recommendations'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      message: json['message'] as String?,
    );
  }
}
