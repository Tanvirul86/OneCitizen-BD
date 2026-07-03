enum ApplicationStatus { submitted, underReview, approved, rejected }

ApplicationStatus applicationStatusFromString(String? value) {
  switch (value?.toLowerCase()) {
    case 'under_review':
      return ApplicationStatus.underReview;
    case 'approved':
      return ApplicationStatus.approved;
    case 'rejected':
      return ApplicationStatus.rejected;
    default:
      return ApplicationStatus.submitted;
  }
}

String applicationStatusToString(ApplicationStatus status) {
  switch (status) {
    case ApplicationStatus.submitted:
      return 'submitted';
    case ApplicationStatus.underReview:
      return 'under_review';
    case ApplicationStatus.approved:
      return 'approved';
    case ApplicationStatus.rejected:
      return 'rejected';
  }
}

class Application {
  const Application({
    required this.id,
    required this.cardTypeId,
    required this.cardTypeName,
    required this.status,
    required this.submittedAt,
    this.updatedAt,
    this.adminRemark,
    this.applicantName,
    this.applicantNid,
    this.applicantEmail,
  });

  final String id;
  final String cardTypeId;
  final String cardTypeName;
  final ApplicationStatus status;
  final DateTime submittedAt;
  final DateTime? updatedAt;
  final String? adminRemark;
  final String? applicantName;
  final String? applicantNid;
  final String? applicantEmail;

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      id: json['id']?.toString() ?? '',
      cardTypeId: json['card_type_id']?.toString() ?? '',
      cardTypeName: json['card_type_name'] as String? ?? '',
      status: applicationStatusFromString(json['status'] as String?),
      submittedAt: DateTime.tryParse(json['submitted_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
      adminRemark: json['admin_remark'] as String?,
      applicantName: json['applicant_name'] as String?,
      applicantNid: json['applicant_nid'] as String?,
      applicantEmail: json['applicant_email'] as String?,
    );
  }
}
