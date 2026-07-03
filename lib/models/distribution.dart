enum DistributionMethod { online, offline }

DistributionMethod distributionMethodFromString(String? value) {
  return value?.toLowerCase() == 'offline'
      ? DistributionMethod.offline
      : DistributionMethod.online;
}

String distributionMethodToString(DistributionMethod method) {
  return method == DistributionMethod.offline ? 'offline' : 'online';
}

class Distribution {
  const Distribution({
    required this.id,
    required this.applicationId,
    required this.method,
    required this.amount,
    required this.distributionDate,
    this.note,
    this.cardTypeName,
    this.citizenName,
  });

  final String id;
  final String applicationId;
  final DistributionMethod method;
  final double amount;
  final DateTime distributionDate;
  final String? note;
  final String? cardTypeName;
  final String? citizenName;

  factory Distribution.fromJson(Map<String, dynamic> json) {
    return Distribution(
      id: json['id']?.toString() ?? '',
      applicationId: json['app_id']?.toString() ?? '',
      method: distributionMethodFromString(json['method'] as String?),
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      distributionDate:
          DateTime.tryParse(json['dist_date'] as String? ?? '') ??
              DateTime.now(),
      note: json['note'] as String?,
      cardTypeName: json['card_type_name'] as String?,
      citizenName: json['citizen_name'] as String?,
    );
  }
}
