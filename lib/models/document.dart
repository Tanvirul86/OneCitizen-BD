/// Citizen-uploaded document. `isValid == null` means pending review.
class CitizenDocument {
  const CitizenDocument({
    required this.id,
    required this.citizenId,
    required this.docType,
    required this.fileUrl,
    this.isValid,
    this.remark,
    this.uploadedAt,
    this.citizenName,
  });

  final String id;
  final String citizenId;
  final String docType;
  final String fileUrl;
  final bool? isValid;
  final String? remark;
  final DateTime? uploadedAt;
  final String? citizenName;

  factory CitizenDocument.fromJson(Map<String, dynamic> json) {
    return CitizenDocument(
      id: json['id']?.toString() ?? '',
      citizenId: json['citizen_id']?.toString() ?? '',
      docType: json['doc_type'] as String? ?? '',
      fileUrl: json['file_url'] as String? ?? '',
      isValid: json['is_valid'] as bool?,
      remark: json['remark'] as String?,
      uploadedAt: json['uploaded_at'] != null
          ? DateTime.tryParse(json['uploaded_at'] as String)
          : null,
      citizenName: json['citizen_name'] as String?,
    );
  }
}

const requiredDocumentTypes = <String>[
  'nid_copy',
  'income_certificate',
  'land_ownership',
  'agricultural_certificate',
  'ssc_marksheet',
  'hsc_marksheet',
  'ward_union_certificate',
];

String documentTypeLabel(String docType) {
  switch (docType) {
    case 'nid_copy':
      return 'NID Copy';
    case 'income_certificate':
      return 'Income Certificate';
    case 'land_ownership':
      return 'Land Ownership Document';
    case 'agricultural_certificate':
      return 'Agricultural Certificate';
    case 'ssc_marksheet':
      return 'SSC Marksheet';
    case 'hsc_marksheet':
      return 'HSC Marksheet';
    case 'ward_union_certificate':
      return 'Ward/Union Authority Certificate';
    default:
      return docType;
  }
}
