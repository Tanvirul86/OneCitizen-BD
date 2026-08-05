import 'package:firebase_database/firebase_database.dart';
import 'package:onecitizen/services/realtime_db.dart';

/// Populates the `card_types` node with the three OneCitizen BD card types
/// the first time the app connects to a fresh Realtime Database. Safe to
/// call on every startup — it only writes when the node is empty.
Future<void> seedCardTypes({FirebaseDatabase? database}) async {
  final db = database ?? appDatabase;
  final cardTypes = db.ref('card_types');

  final existing = await cardTypes.limitToFirst(1).get();
  if (existing.exists) return;

  await cardTypes.set({
    'ct-farmer': {
      'code': 'farmer',
      'name': 'Farmer Card',
      'eligibility_criteria':
          'Must be a registered farmer with a valid certificate from the local ward/union authority.',
      'required_documents': ['nid_copy', 'agricultural_certificate', 'ward_union_certificate'],
    },
    'ct-family': {
      'code': 'family',
      'name': 'Family Card',
      'eligibility_criteria':
          'Must own land of ≤ 0.50 acres, have a monthly household income ≤ BDT 12,000, and hold a certificate from the local ward/union authority.',
      'required_documents': [
        'nid_copy',
        'income_certificate',
        'land_ownership',
        'ward_union_certificate',
      ],
    },
    'ct-education': {
      'code': 'education',
      'name': 'Education Card',
      'eligibility_criteria': 'Must have achieved GPA 5.00 in both SSC and HSC examinations.',
      'required_documents': ['nid_copy', 'ssc_marksheet', 'hsc_marksheet'],
    },
  });
}
