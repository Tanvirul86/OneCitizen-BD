import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:firebase_database/firebase_database.dart';
import 'package:onecitizen/models/application.dart';
import 'package:onecitizen/models/card_type.dart';
import 'package:onecitizen/models/distribution.dart';
import 'package:onecitizen/models/document.dart';
import 'package:onecitizen/models/notification.dart';
import 'package:onecitizen/models/user.dart';
import 'package:onecitizen/services/auth_service.dart';
import 'package:onecitizen/services/realtime_db.dart';

String _requireUid() {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) throw AuthException('You must be signed in.');
  return uid;
}

void _sortByDate(List<Map<String, dynamic>> items, String field) {
  items.sort((a, b) => (b[field] as String? ?? '').compareTo(a[field] as String? ?? ''));
}

Future<void> _notifyAdmins(FirebaseDatabase database, String message) {
  return database.ref('admin_notifications').push().set({
    'message': message,
    'created_at': ServerValue.timestamp,
    'is_read': false,
  });
}

class CardTypeService {
  CardTypeService({FirebaseDatabase? database}) : _database = database ?? appDatabase;
  final FirebaseDatabase _database;

  Future<List<CardType>> getCardTypes() async {
    final snapshot = await _database.ref('card_types').get();
    return mapChildren(snapshot).map(CardType.fromJson).toList();
  }
}

class EligibilityService {
  EligibilityService({FirebaseDatabase? database}) : _database = database ?? appDatabase;
  final FirebaseDatabase _database;

  Future<EligibilityResult> checkEligibility() async {
    final uid = _requireUid();
    final userSnapshot = await _database.ref('users').child(uid).get();
    if (!userSnapshot.exists) throw AuthException('Profile not found.');
    final user = User.fromJson(withKey(uid, userSnapshot.value));

    final cardTypesSnapshot = await _database.ref('card_types').get();
    final cardTypes = mapChildren(cardTypesSnapshot).map(CardType.fromJson).toList();

    return EligibilityResult(
      results: cardTypes.map((cardType) => _evaluate(cardType, user)).toList(),
    );
  }

  CardEligibility _evaluate(CardType cardType, User user) {
    switch (cardType.code) {
      case CardTypeCode.farmer:
        final eligible = user.occupation?.toLowerCase() == 'farmer';
        return CardEligibility(
          cardType: cardType,
          eligible: eligible,
          reason: eligible
              ? 'Registered occupation on file is farmer.'
              : 'Occupation on file is not farmer.',
        );
      case CardTypeCode.family:
        final isFemale = user.gender?.toLowerCase() == 'female';
        final land = user.landAcres;
        final income = user.income;
        final eligible =
            isFemale && land != null && income != null && land <= 0.5 && income <= 12000;
        return CardEligibility(
          cardType: cardType,
          eligible: eligible,
          reason: !isFemale
              ? 'Family Card is only available for women applicants.'
              : eligible
              ? 'Land holding and income are within the allowed limits.'
              : 'Land holding or monthly income exceeds the allowed limits.',
        );
      case CardTypeCode.education:
        final ssc = user.sscGpa;
        final hsc = user.hscGpa;
        final eligible = ssc != null && hsc != null && ssc >= 5.0 && hsc >= 5.0;
        return CardEligibility(
          cardType: cardType,
          eligible: eligible,
          reason: eligible
              ? 'GPA 5.00 achieved in both SSC and HSC.'
              : 'GPA requirement not met in SSC and/or HSC.',
        );
    }
  }

  Future<Map<String, dynamic>> submitEligibilityRequest(Map<String, dynamic> data) async {
    final uid = _requireUid();
    final ref = _database.ref('eligibility_requests').push();
    await ref.set({
      'citizen_id': uid,
      'status': 'pending_review',
      'submitted_at': ServerValue.timestamp,
      ...data,
    });
    await _notifyAdmins(_database, 'A citizen submitted a new eligibility request.');
    return {
      'status': 'pending_review',
      'message':
          'Your eligibility request has been submitted. Admin will review and notify you shortly.',
    };
  }
}

class ApplicationService {
  ApplicationService({FirebaseDatabase? database}) : _database = database ?? appDatabase;
  final FirebaseDatabase _database;

  DatabaseReference get _applications => _database.ref('applications');

  Future<List<Application>> getApplications() async {
    final uid = _requireUid();
    final snapshot = await _applications.orderByChild('citizen_id').equalTo(uid).get();
    final items = mapChildren(snapshot);
    _sortByDate(items, 'submitted_at');
    return items.map(Application.fromJson).toList();
  }

  Future<Application> getApplication(String id) async {
    final snapshot = await _applications.child(id).get();
    if (!snapshot.exists) throw AuthException('Application not found.');
    return Application.fromJson(withKey(id, snapshot.value));
  }

  Future<Application> submitApplication({
    required String cardTypeId,
    required Map<String, String> applicationData,
  }) async {
    final uid = _requireUid();

    // Claiming this lock atomically (instead of the read-then-write check it
    // replaces) closes the race where two concurrent submissions for the
    // same card type both pass the "no active application" check.
    final lockRef = _database.ref('application_locks').child('${uid}_$cardTypeId');
    final lockResult = await lockRef.runTransaction((current) {
      if (current != null) return Transaction.abort();
      return Transaction.success({'citizen_id': uid, 'card_type_id': cardTypeId});
    });
    if (!lockResult.committed) {
      throw AuthException(
        'You already have an application for this card type. '
        'Wait for it to be reviewed before applying again.',
      );
    }

    try {
      final cardTypeSnapshot = await _database.ref('card_types').child(cardTypeId).get();
      if (!cardTypeSnapshot.exists) throw AuthException('Selected card type was not found.');
      final cardTypeData = Map<String, dynamic>.from(cardTypeSnapshot.value as Map);

      final userSnapshot = await _database.ref('users').child(uid).get();
      final userData = Map<String, dynamic>.from(userSnapshot.value as Map? ?? {});

      if (cardTypeData['code'] == 'family' &&
          (userData['gender'] as String?)?.toLowerCase() != 'female') {
        throw AuthException('Family Card is only available for women applicants.');
      }

      // The apply wizard collects the NID/birth-certificate number as part
      // of the card-specific form — if the profile doesn't have one on
      // file yet, back-fill it from whichever of the application's NID
      // fields the citizen filled in.
      const nidFieldKeys = ['nid_card_number', 'nid_birth_certificate_number'];
      final submittedNid = nidFieldKeys
          .map((key) => applicationData[key])
          .firstWhere(
            (value) => value != null && value.trim().isNotEmpty,
            orElse: () => null,
          )
          ?.trim();
      final existingNid = (userData['nid'] as String?)?.trim();
      if (submittedNid != null && (existingNid == null || existingNid.isEmpty)) {
        await _database.ref('users').child(uid).update({'nid': submittedNid});
        userData['nid'] = submittedNid;
      }

      final record = {
        'citizen_id': uid,
        'card_type_id': cardTypeId,
        'card_type_name': cardTypeData['name'],
        'applicant_name': [userData['first_name'], userData['last_name']]
            .where((e) => e != null && (e as String).isNotEmpty)
            .join(' '),
        'applicant_nid': userData['nid'],
        'applicant_email': userData['email'],
        'application_data': applicationData,
        'status': 'submitted',
        'submitted_at': ServerValue.timestamp,
        'updated_at': ServerValue.timestamp,
      };

      final ref = _applications.push();
      await ref.set(record);
      await lockRef.update({'application_id': ref.key});

      // Documents are uploaded one at a time during the apply wizard, before
      // this application exists, so they aren't linked to it yet — attach
      // whichever of the card type's required documents the citizen already
      // has on file (keyed by `${uid}_$docType`, no application id) now that
      // there's an application id to attach them to.
      final requiredDocuments = (cardTypeData['required_documents'] as List?) ?? [];
      final documentsRef = _database.ref('documents');
      for (final docType in requiredDocuments) {
        final docRef = documentsRef.child('${uid}_$docType');
        final docSnapshot = await docRef.get();
        if (docSnapshot.exists) {
          await docRef.update({'application_id': ref.key, 'card_type_id': cardTypeId});
        }
      }

      await _notifyAdmins(
        _database,
        'A citizen submitted a new ${cardTypeData['name']} application.',
      );
      final snapshot = await ref.get();
      return Application.fromJson(withKey(ref.key!, snapshot.value));
    } catch (e) {
      // The application never got created (or we failed before recording
      // it) — release the lock so the citizen isn't stuck unable to apply.
      await lockRef.remove();
      rethrow;
    }
  }
}

const _maxDocumentBytes = 5 * 1024 * 1024; // 5MB raw — keeps the base64 node well under RTDB's 10MB cap.

const _mimeTypesByExtension = {
  'jpg': 'image/jpeg',
  'jpeg': 'image/jpeg',
  'png': 'image/png',
  'pdf': 'application/pdf',
  'doc': 'application/msword',
  'docx': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
};

class DocumentService {
  DocumentService({FirebaseDatabase? database}) : _database = database ?? appDatabase;
  final FirebaseDatabase _database;

  DatabaseReference get _documents => _database.ref('documents');

  Future<List<CitizenDocument>> getDocuments() async {
    final uid = _requireUid();
    final snapshot = await _documents.orderByChild('citizen_id').equalTo(uid).get();
    return mapChildren(snapshot).map(CitizenDocument.fromJson).toList();
  }

  Future<CitizenDocument> uploadDocument({
    required String docType,
    required String filePath,
    String? applicationId,
  }) async {
    final uid = _requireUid();
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    if (bytes.length > _maxDocumentBytes) {
      throw AuthException('File is too large — please upload something under 5MB.');
    }
    final extension = filePath.contains('.') ? filePath.split('.').last.toLowerCase() : '';
    final mimeType = _mimeTypesByExtension[extension] ?? 'application/octet-stream';
    final fileUrl = 'data:$mimeType;base64,${base64Encode(bytes)}';

    final userSnapshot = await _database.ref('users').child(uid).get();
    final userData = Map<String, dynamic>.from(userSnapshot.value as Map? ?? {});
    final citizenName = [userData['first_name'], userData['last_name']]
        .where((e) => e != null && (e as String).isNotEmpty)
        .join(' ');

    String? cardTypeId;
    String? linkedApplicationId = applicationId;
    if (applicationId != null) {
      final applicationSnapshot = await _database.ref('applications').child(applicationId).get();
      if (applicationSnapshot.exists) {
        cardTypeId = (applicationSnapshot.value as Map)['card_type_id'] as String?;
      }
    } else {
      // Uploaded without an application in progress — e.g. the citizen
      // submitted first and added/replaced a document afterward. Attach it
      // to their active application for a card type that requires this
      // doc, so it doesn't stay invisible to admin review.
      final applicationsSnapshot =
          await _database.ref('applications').orderByChild('citizen_id').equalTo(uid).get();
      for (final application in mapChildren(applicationsSnapshot)) {
        if (application['status'] == 'rejected') continue;
        final candidateCardTypeId = application['card_type_id'] as String?;
        if (candidateCardTypeId == null) continue;
        final cardTypeSnapshot =
            await _database.ref('card_types').child(candidateCardTypeId).get();
        if (!cardTypeSnapshot.exists) continue;
        final requiredDocuments =
            (Map<String, dynamic>.from(cardTypeSnapshot.value as Map)['required_documents']
                    as List?) ??
                [];
        if (requiredDocuments.contains(docType)) {
          linkedApplicationId = application['id'] as String?;
          cardTypeId = candidateCardTypeId;
          break;
        }
      }
    }

    final docId = applicationId != null ? '${uid}_${applicationId}_$docType' : '${uid}_$docType';
    await _documents.child(docId).set({
      'citizen_id': uid,
      'doc_type': docType,
      'file_url': fileUrl,
      'uploaded_at': ServerValue.timestamp,
      'citizen_name': citizenName,
      'citizen_email': userData['email'],
      'application_id': linkedApplicationId,
      'card_type_id': cardTypeId,
    });

    final snapshot = await _documents.child(docId).get();
    return CitizenDocument.fromJson(withKey(docId, snapshot.value));
  }
}

class DistributionService {
  DistributionService({FirebaseDatabase? database}) : _database = database ?? appDatabase;
  final FirebaseDatabase _database;

  Future<List<Distribution>> getDistributions() async {
    final uid = _requireUid();
    final snapshot =
        await _database.ref('distributions').orderByChild('citizen_id').equalTo(uid).get();
    final items = mapChildren(snapshot);
    _sortByDate(items, 'dist_date');
    return items.map(Distribution.fromJson).toList();
  }
}

class NotificationService {
  NotificationService({FirebaseDatabase? database}) : _database = database ?? appDatabase;
  final FirebaseDatabase _database;

  DatabaseReference get _notifications => _database.ref('notifications');

  Future<List<AppNotification>> getNotifications() async {
    final uid = _requireUid();
    final snapshot = await _notifications.orderByChild('citizen_id').equalTo(uid).get();
    final items = mapChildren(snapshot);
    _sortByDate(items, 'created_at');
    return items.map(AppNotification.fromJson).toList();
  }

  Future<void> markAsRead(String id) async {
    await _notifications.child(id).update({'is_read': true});
  }
}
