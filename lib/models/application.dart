enum ApplicationStatus {
  submitted,
  underReview,
  approved,
  rejected,
  documentRequested,
}

ApplicationStatus applicationStatusFromString(String? value) {
  switch (value?.toLowerCase()) {
    case 'under_review':
      return ApplicationStatus.underReview;
    case 'approved':
      return ApplicationStatus.approved;
    case 'rejected':
      return ApplicationStatus.rejected;
    case 'document_requested':
      return ApplicationStatus.documentRequested;
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
    case ApplicationStatus.documentRequested:
      return 'document_requested';
  }
}

class ApplicationTimelineEntry {
  const ApplicationTimelineEntry({
    required this.status,
    required this.timestamp,
    this.remarks,
    this.officerName,
  });

  final ApplicationStatus status;
  final DateTime timestamp;
  final String? remarks;
  final String? officerName;

  factory ApplicationTimelineEntry.fromJson(Map<String, dynamic> json) {
    return ApplicationTimelineEntry(
      status: applicationStatusFromString(json['status'] as String?),
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ??
          DateTime.now(),
      remarks: json['remarks'] as String?,
      officerName: json['officer_name'] as String?,
    );
  }
}

class ApplicationDocument {
  const ApplicationDocument({
    required this.id,
    required this.name,
    required this.url,
    this.documentType,
  });

  final String id;
  final String name;
  final String url;
  final String? documentType;

  factory ApplicationDocument.fromJson(Map<String, dynamic> json) {
    return ApplicationDocument(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? 'Document',
      url: json['url'] as String? ?? '',
      documentType: json['document_type'] as String?,
    );
  }
}

class Application {
  const Application({
    required this.id,
    required this.cardType,
    required this.cardTypeName,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.remarks,
    this.documents = const [],
    this.timeline = const [],
    this.applicantName,
    this.applicantNid,
    this.applicantPhone,
  });

  final String id;
  final String cardType;
  final String cardTypeName;
  final ApplicationStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? remarks;
  final List<ApplicationDocument> documents;
  final List<ApplicationTimelineEntry> timeline;
  final String? applicantName;
  final String? applicantNid;
  final String? applicantPhone;

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      id: json['id']?.toString() ?? '',
      cardType: json['card_type']?.toString() ?? '',
      cardTypeName: json['card_type_name'] as String? ?? '',
      status: applicationStatusFromString(json['status'] as String?),
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
      remarks: json['remarks'] as String?,
      documents: (json['documents'] as List<dynamic>?)
              ?.map((e) => ApplicationDocument.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      timeline: (json['timeline'] as List<dynamic>?)
              ?.map((e) =>
                  ApplicationTimelineEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      applicantName: json['applicant_name'] as String?,
      applicantNid: json['applicant_nid'] as String?,
      applicantPhone: json['applicant_phone'] as String?,
    );
  }
}
