enum CardStatus { active, expired, suspended, pending }

CardStatus cardStatusFromString(String? value) {
  switch (value?.toLowerCase()) {
    case 'expired':
      return CardStatus.expired;
    case 'suspended':
      return CardStatus.suspended;
    case 'pending':
      return CardStatus.pending;
    default:
      return CardStatus.active;
  }
}

class CitizenCard {
  const CitizenCard({
    required this.id,
    required this.cardNumber,
    required this.cardType,
    required this.cardTypeName,
    required this.status,
    this.issuedAt,
    this.expiresAt,
    this.holderName,
    this.qrPayload,
  });

  final String id;
  final String cardNumber;
  final String cardType;
  final String cardTypeName;
  final CardStatus status;
  final DateTime? issuedAt;
  final DateTime? expiresAt;
  final String? holderName;
  final String? qrPayload;

  factory CitizenCard.fromJson(Map<String, dynamic> json) {
    return CitizenCard(
      id: json['id']?.toString() ?? '',
      cardNumber: json['card_number'] as String? ?? '',
      cardType: json['card_type']?.toString() ?? '',
      cardTypeName: json['card_type_name'] as String? ?? '',
      status: cardStatusFromString(json['status'] as String?),
      issuedAt: json['issued_at'] != null
          ? DateTime.tryParse(json['issued_at'] as String)
          : null,
      expiresAt: json['expires_at'] != null
          ? DateTime.tryParse(json['expires_at'] as String)
          : null,
      holderName: json['holder_name'] as String?,
      qrPayload: json['qr_payload'] as String?,
    );
  }

  String get qrData => qrPayload ?? cardNumber;
}
