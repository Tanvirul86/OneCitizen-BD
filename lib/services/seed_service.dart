import 'package:firebase_database/firebase_database.dart';
import 'package:onecitizen/services/realtime_db.dart';

/// The three OneCitizen BD card types — required documents, the dynamic
/// application-form fields, and the fixed per-citizen disbursement amount.
/// Card type ids are stable identifiers other records (`applications`,
/// `documents`) reference by `card_type_id`, so they must never change once
/// live data exists.
const _cardTypesData = {
  'ct-farmer': {
    'code': 'farmer',
    'name': 'Farmer Card',
    'eligibility_criteria':
        'Must be a registered farmer with a valid certificate from the local ward/union authority.',
    'disbursement_amount': 5000,
    'required_documents': [
      'nid_copy',
      'union_paurosova_certificate',
      'recent_photo',
      'agricultural_certificate',
    ],
    'application_fields': [
      {'key': 'first_name', 'label': 'First name', 'required': true},
      {'key': 'last_name', 'label': 'Last name', 'required': true},
      {
        'key': 'nid_card_number',
        'label': 'NID card number',
        'required': true,
        'input_type': 'number',
      },
      {
        'key': 'date_of_birth',
        'label': 'Date of birth',
        'hint': 'DD/MM/YYYY',
        'required': true,
        'input_type': 'date',
      },
      {
        'key': 'phone_number',
        'label': 'Phone number linked with own NID',
        'required': true,
        'input_type': 'phone',
      },
      {
        'key': 'mobile_wallet',
        'label': 'Mobile financial service',
        'required': true,
        'options': ['bKash', 'Nagad'],
      },
      {
        'key': 'cultivated_land_amount',
        'label': 'Cultivated land amount',
        'required': true,
        'input_type': 'number',
      },
      {
        'key': 'land_unit',
        'label': 'Land measuring unit',
        'required': true,
        'options': ['Decimal', 'Katha', 'Bigha', 'Acre'],
      },
      {'key': 'village_road', 'label': 'Village/Road/House', 'required': true},
    ],
  },
  'ct-family': {
    'code': 'family',
    'name': 'Family Card',
    'eligibility_criteria':
        'Must own land of ≤ 0.50 acres, have a monthly household income ≤ BDT 12,000, and hold a certificate from the local ward/union authority.',
    'disbursement_amount': 8000,
    'required_documents': [
      'nid_copy',
      'union_paurosova_certificate',
      'recent_photo',
      'income_certificate',
    ],
    'application_fields': [
      {'key': 'first_name', 'label': 'First name', 'required': true},
      {'key': 'last_name', 'label': 'Last name', 'required': true},
      {
        'key': 'nid_card_number',
        'label': 'NID card number',
        'required': true,
        'input_type': 'number',
      },
      {
        'key': 'date_of_birth',
        'label': 'Date of birth',
        'hint': 'DD/MM/YYYY',
        'required': true,
        'input_type': 'date',
      },
      {
        'key': 'phone_number',
        'label': 'Phone number linked with own NID',
        'required': true,
        'input_type': 'phone',
      },
      {
        'key': 'mobile_wallet',
        'label': 'Mobile financial service',
        'required': true,
        'options': ['bKash', 'Nagad'],
      },
      {
        'key': 'family_members',
        'label': 'Number of family members',
        'required': true,
        'input_type': 'number',
      },
      {
        'key': 'monthly_income',
        'label': 'Monthly household income',
        'required': true,
        'input_type': 'number',
      },
      {
        'key': 'dependents',
        'label': 'Number of dependents',
        'required': true,
        'input_type': 'number',
      },
      {'key': 'village_road', 'label': 'Village/Road/House', 'required': true},
    ],
  },
  'ct-education': {
    'code': 'education',
    'name': 'Education Card',
    'eligibility_criteria':
        'Must have achieved GPA 5.00 in both SSC and HSC examinations.',
    'disbursement_amount': 12000,
    'required_documents': [
      'nid_birth_certificate',
      'ssc_certificate',
      'hsc_certificate',
      'recent_photo',
    ],
    'application_fields': [
      {
        'key': 'student_first_name',
        'label': 'Student first name',
        'required': true,
      },
      {
        'key': 'student_last_name',
        'label': 'Student last name',
        'required': true,
      },
      {'key': 'father_name', 'label': 'Father name', 'required': true},
      {'key': 'mother_name', 'label': 'Mother name', 'required': true},
      {
        'key': 'date_of_birth',
        'label': 'Date of birth',
        'hint': 'DD/MM/YYYY',
        'required': true,
        'input_type': 'date',
      },
      {
        'key': 'nid_birth_certificate_number',
        'label': 'NID/Birth certificate number',
        'required': true,
        'input_type': 'number',
      },
      {
        'key': 'ssc_registration_number',
        'label': 'SSC registration number',
        'required': true,
        'input_type': 'number',
      },
      {
        'key': 'ssc_roll_number',
        'label': 'SSC roll number',
        'required': true,
        'input_type': 'number',
      },
      {
        'key': 'ssc_board',
        'label': 'SSC board',
        'required': true,
        'options': [
          'Dhaka',
          'Chattogram',
          'Rajshahi',
          'Cumilla',
          'Jashore',
          'Barishal',
          'Sylhet',
          'Dinajpur',
          'Mymensingh',
          'Madrasah',
          'Technical',
        ],
      },
      {
        'key': 'ssc_passing_year',
        'label': 'SSC passing year',
        'required': true,
        'input_type': 'number',
      },
      {
        'key': 'hsc_registration_number',
        'label': 'HSC registration number',
        'required': true,
        'input_type': 'number',
      },
      {
        'key': 'hsc_roll_number',
        'label': 'HSC roll number',
        'required': true,
        'input_type': 'number',
      },
      {
        'key': 'hsc_board',
        'label': 'HSC board',
        'required': true,
        'options': [
          'Dhaka',
          'Chattogram',
          'Rajshahi',
          'Cumilla',
          'Jashore',
          'Barishal',
          'Sylhet',
          'Dinajpur',
          'Mymensingh',
          'Madrasah',
          'Technical',
        ],
      },
      {
        'key': 'hsc_passing_year',
        'label': 'HSC passing year',
        'required': true,
        'input_type': 'number',
      },
    ],
  },
};

/// Populates the `card_types` node the first time the app connects to a
/// fresh Realtime Database. Safe to call on every startup — it only writes
/// when the node is empty, so it won't undo an admin's later edits.
Future<void> seedCardTypes({FirebaseDatabase? database}) async {
  final db = database ?? appDatabase;
  final cardTypes = db.ref('card_types');

  final existing = await cardTypes.limitToFirst(1).get();
  if (existing.exists) return;

  await cardTypes.set(_cardTypesData);
}

/// Overwrites `card_types` with the current schema even if the node already
/// has data — for databases seeded before `application_fields` and
/// `disbursement_amount` existed. Card type ids are unchanged, so existing
/// `applications`/`documents` records that reference them by id stay valid.
/// Security rules restrict `card_types` writes to admins, so this silently
/// does nothing (permission-denied) unless called from an admin session —
/// safe to call unconditionally on admin dashboard load.
Future<void> ensureCardTypesUpToDate({FirebaseDatabase? database}) async {
  final db = database ?? appDatabase;
  await db.ref('card_types').update(_cardTypesData);
}

/// Attaches `application_id`/`card_type_id` to any `documents` record still
/// missing them — e.g. a document uploaded after its application was
/// already submitted, so the one-time linking step in `submitApplication`
/// never saw it. Safe to call unconditionally on admin dashboard load.
Future<void> relinkOrphanedDocuments({FirebaseDatabase? database}) async {
  final db = database ?? appDatabase;

  final documentsSnapshot = await db.ref('documents').get();
  final applicationsSnapshot = await db.ref('applications').get();
  final cardTypesSnapshot = await db.ref('card_types').get();

  final applications = mapChildren(applicationsSnapshot);
  final cardTypes = {
    for (final cardType in mapChildren(cardTypesSnapshot))
      cardType['id'] as String: cardType,
  };

  for (final document in mapChildren(documentsSnapshot)) {
    if (document['application_id'] != null) continue;
    final citizenId = document['citizen_id'] as String?;
    final docType = document['doc_type'] as String?;
    if (citizenId == null || docType == null) continue;

    for (final application in applications) {
      if (application['citizen_id'] != citizenId) continue;
      if (application['status'] == 'rejected') continue;
      final cardTypeId = application['card_type_id'] as String?;
      final requiredDocuments =
          (cardTypes[cardTypeId]?['required_documents'] as List?) ?? [];
      if (requiredDocuments.contains(docType)) {
        await db.ref('documents').child(document['id'] as String).update({
          'application_id': application['id'],
          'card_type_id': cardTypeId,
        });
        break;
      }
    }
  }
}

/// Merges duplicate `documents` records for the same citizen/doc-type —
/// a citizen only ever has one copy of a given document on file, but a
/// reupload used to be keyed differently from the original upload, so a
/// rejected document plus its reupload could end up as two separate
/// records instead of one being overwritten. Keeps only the most recently
/// uploaded record per citizen+doc-type and deletes the rest; safe to
/// call unconditionally on admin dashboard load.
Future<void> mergeDuplicateDocuments({FirebaseDatabase? database}) async {
  final db = database ?? appDatabase;
  final documentsSnapshot = await db.ref('documents').get();

  final byCitizenAndType = <String, List<Map<String, dynamic>>>{};
  for (final document in mapChildren(documentsSnapshot)) {
    final citizenId = document['citizen_id'] as String?;
    final docType = document['doc_type'] as String?;
    if (citizenId == null || docType == null) continue;
    byCitizenAndType
        .putIfAbsent('${citizenId}_$docType', () => [])
        .add(document);
  }

  for (final group in byCitizenAndType.values) {
    if (group.length <= 1) continue;
    group.sort(
      (a, b) => (a['uploaded_at'] as String? ?? '').compareTo(
        b['uploaded_at'] as String? ?? '',
      ),
    );
    for (final stale in group.sublist(0, group.length - 1)) {
      await db.ref('documents').child(stale['id'] as String).remove();
    }
  }
}
