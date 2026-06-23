enum ComplaintStatus { open, inProgress, resolved }

ComplaintStatus complaintStatusFromString(String? value) {
  switch (value?.toLowerCase()) {
    case 'in_progress':
      return ComplaintStatus.inProgress;
    case 'resolved':
      return ComplaintStatus.resolved;
    default:
      return ComplaintStatus.open;
  }
}

class Complaint {
  const Complaint({
    required this.id,
    required this.subject,
    required this.description,
    required this.status,
    required this.createdAt,
    this.resolution,
    this.resolvedAt,
    this.citizenName,
  });

  final String id;
  final String subject;
  final String description;
  final ComplaintStatus status;
  final DateTime createdAt;
  final String? resolution;
  final DateTime? resolvedAt;
  final String? citizenName;

  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      id: json['id']?.toString() ?? '',
      subject: json['subject'] as String? ?? '',
      description: json['description'] as String? ?? '',
      status: complaintStatusFromString(json['status'] as String?),
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      resolution: json['resolution'] as String?,
      resolvedAt: json['resolved_at'] != null
          ? DateTime.tryParse(json['resolved_at'] as String)
          : null,
      citizenName: json['citizen_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'subject': subject,
        'description': description,
      };
}
