import 'package:firebase_database/firebase_database.dart';
import 'package:onecitizen/models/application.dart';
import 'package:onecitizen/models/distribution.dart';
import 'package:onecitizen/models/document.dart';
import 'package:onecitizen/models/notification.dart';
import 'package:onecitizen/models/user.dart';
import 'package:onecitizen/services/auth_service.dart';
import 'package:onecitizen/services/realtime_db.dart';

void _sortByDate(List<Map<String, dynamic>> items, String field) {
  items.sort((a, b) => (b[field] as String? ?? '').compareTo(a[field] as String? ?? ''));
}

class AdminService {
  AdminService({FirebaseDatabase? database}) : _database = database ?? appDatabase;
  final FirebaseDatabase _database;

  DatabaseReference get _applications => _database.ref('applications');
  DatabaseReference get _documents => _database.ref('documents');
  DatabaseReference get _distributions => _database.ref('distributions');
  DatabaseReference get _users => _database.ref('users');
  DatabaseReference get _notifications => _database.ref('notifications');

  Future<void> _notify(String citizenId, String message) {
    return _notifications.push().set({
      'citizen_id': citizenId,
      'message': message,
      'created_at': ServerValue.timestamp,
      'is_read': false,
    });
  }

  // ── Applications ─────────────────────────────────────────────────────────
  Future<List<Application>> getApplications({
    String? cardTypeId,
    ApplicationStatus? status,
  }) async {
    final snapshot = await _applications.get();
    var items = mapChildren(snapshot);
    if (cardTypeId != null && cardTypeId.isNotEmpty) {
      items = items.where((a) => a['card_type_id'] == cardTypeId).toList();
    }
    if (status != null) {
      items = items.where((a) => a['status'] == applicationStatusToString(status)).toList();
    }
    _sortByDate(items, 'submitted_at');
    return items.map(Application.fromJson).toList();
  }

  Future<Application> getApplication(String id) async {
    final snapshot = await _applications.child(id).get();
    if (!snapshot.exists) throw AuthException('Application not found.');
    return Application.fromJson(withKey(id, snapshot.value));
  }

  Future<Application> approveApplication(String id) async {
    await _applications.child(id).update({
      'status': 'approved',
      'updated_at': ServerValue.timestamp,
    });
    final application = await getApplication(id);
    final citizenId = (await _applications.child(id).child('citizen_id').get()).value as String;
    await _notify(citizenId, 'Your ${application.cardTypeName} application has been approved.');
    return application;
  }

  Future<Application> rejectApplication(String id, {required String reason}) async {
    await _applications.child(id).update({
      'status': 'rejected',
      'admin_remark': reason,
      'updated_at': ServerValue.timestamp,
    });
    final application = await getApplication(id);
    final citizenId = (await _applications.child(id).child('citizen_id').get()).value as String;
    await _notify(
      citizenId,
      'Your ${application.cardTypeName} application was rejected: $reason',
    );
    return application;
  }

  // ── Document validation ─────────────────────────────────────────────────
  Future<List<CitizenDocument>> getDocuments({
    String? citizenId,
    String? citizenEmail,
  }) async {
    final snapshot = await _documents.get();
    var items = mapChildren(snapshot);
    if (citizenId != null && citizenId.isNotEmpty) {
      items = items.where((d) => d['citizen_id'] == citizenId).toList();
    }
    if (citizenEmail != null && citizenEmail.isNotEmpty) {
      final query = citizenEmail.toLowerCase();
      items = items
          .where((d) => (d['citizen_name'] as String? ?? '').toLowerCase().contains(query))
          .toList();
    }
    _sortByDate(items, 'uploaded_at');
    return items.map(CitizenDocument.fromJson).toList();
  }

  Future<CitizenDocument> validateDocument(
    String id, {
    required bool isValid,
    String? remark,
  }) async {
    await _documents.child(id).update({'is_valid': isValid, 'remark': remark});
    final snapshot = await _documents.child(id).get();
    final data = Map<String, dynamic>.from(snapshot.value as Map);
    await _notify(
      data['citizen_id'] as String,
      isValid
          ? 'Document "${documentTypeLabel(data['doc_type'] as String? ?? '')}" was verified.'
          : 'Document "${documentTypeLabel(data['doc_type'] as String? ?? '')}" was marked invalid.'
              '${remark != null && remark.isNotEmpty ? ' $remark' : ''}',
    );
    return CitizenDocument.fromJson(withKey(id, snapshot.value));
  }

  // ── Fund distribution ────────────────────────────────────────────────────
  Future<Distribution> createDistribution({
    required String applicationId,
    required DistributionMethod method,
    required double amount,
    String? note,
  }) async {
    final applicationSnapshot = await _applications.child(applicationId).get();
    if (!applicationSnapshot.exists) throw AuthException('Application not found.');
    final applicationData = Map<String, dynamic>.from(applicationSnapshot.value as Map);

    final citizenId = applicationData['citizen_id'] as String;
    final ref = _distributions.push();
    await ref.set({
      'citizen_id': citizenId,
      'app_id': applicationId,
      'method': distributionMethodToString(method),
      'amount': amount,
      'dist_date': ServerValue.timestamp,
      'note': note,
      'card_type_name': applicationData['card_type_name'],
      'citizen_name': applicationData['applicant_name'],
    });
    final snapshot = await ref.get();

    await _notify(
      citizenId,
      'BDT ${amount.toStringAsFixed(0)} has been disbursed for your '
      '${applicationData['card_type_name']} via ${distributionMethodToString(method)}.',
    );

    return Distribution.fromJson(withKey(ref.key!, snapshot.value));
  }

  Future<List<Distribution>> getDistributions({
    String? cardTypeId,
    DistributionMethod? method,
  }) async {
    final snapshot = await _distributions.get();
    var items = mapChildren(snapshot);
    if (method != null) {
      items = items.where((d) => d['method'] == distributionMethodToString(method)).toList();
    }
    if (cardTypeId != null && cardTypeId.isNotEmpty) {
      items = items.where((d) => d['card_type_name'] == cardTypeId).toList();
    }
    _sortByDate(items, 'dist_date');
    return items.map(Distribution.fromJson).toList();
  }

  // ── Citizen accounts ──────────────────────────────────────────────────────
  Future<List<User>> getCitizens({String? search}) async {
    final snapshot = await _users.get();
    var citizens = mapChildren(snapshot)
        .where((u) => u['role'] == 'citizen')
        .map(User.fromJson)
        .toList();
    if (search != null && search.isNotEmpty) {
      final query = search.toLowerCase();
      citizens = citizens
          .where((c) =>
              c.fullName.toLowerCase().contains(query) ||
              c.email.toLowerCase().contains(query) ||
              (c.nid ?? '').contains(query))
          .toList();
    }
    return citizens;
  }

  Future<User> getCitizen(String id) async {
    final snapshot = await _users.child(id).get();
    if (!snapshot.exists) throw AuthException('Citizen not found.');
    return User.fromJson(withKey(id, snapshot.value));
  }

  Future<void> deactivateCitizen(String id) async {
    await _users.child(id).update({'is_active': false});
  }

  Future<void> activateCitizen(String id) async {
    await _users.child(id).update({'is_active': true});
  }

  Future<void> freezeCitizen(String id) async {
    await _users.child(id).update({'is_frozen': true});
  }

  Future<void> unfreezeCitizen(String id) async {
    await _users.child(id).update({'is_frozen': false});
  }

  // ── Analytics ────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getAnalytics() async {
    final applications = mapChildren(await _applications.get());
    final distributions = mapChildren(await _distributions.get());
    final documents = mapChildren(await _documents.get());

    final byCardType = <String, int>{};
    var approved = 0;
    var rejected = 0;
    var pendingReview = 0;
    for (final data in applications) {
      final cardTypeName = data['card_type_name'] as String? ?? 'Unknown';
      byCardType[cardTypeName] = (byCardType[cardTypeName] ?? 0) + 1;
      switch (data['status'] as String?) {
        case 'approved':
          approved++;
          break;
        case 'rejected':
          rejected++;
          break;
        default:
          pendingReview++;
      }
    }

    final pendingDocumentReviews = documents.where((d) => d['is_valid'] == null).length;

    var totalDisbursed = 0.0;
    for (final data in distributions) {
      totalDisbursed += (data['amount'] as num?)?.toDouble() ?? 0;
    }

    return {
      'total_applications': applications.length,
      'applications_by_card_type': byCardType,
      'approved': approved,
      'rejected': rejected,
      'pending_review': pendingReview,
      'pending_document_reviews': pendingDocumentReviews,
      'total_disbursed': totalDisbursed,
    };
  }
}

class AdminNotificationService {
  AdminNotificationService({FirebaseDatabase? database}) : _database = database ?? appDatabase;
  final FirebaseDatabase _database;

  DatabaseReference get _adminNotifications => _database.ref('admin_notifications');

  Future<List<AppNotification>> getNotifications() async {
    final snapshot = await _adminNotifications.get();
    final items = mapChildren(snapshot);
    _sortByDate(items, 'created_at');
    return items.map(AppNotification.fromJson).toList();
  }

  Future<void> markAsRead(String id) async {
    await _adminNotifications.child(id).update({'is_read': true});
  }
}
