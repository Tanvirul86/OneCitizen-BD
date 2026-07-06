import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:onecitizen/config/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// In debug mode, intercepts all HTTP requests and returns mock JSON so the
/// app is fully navigable without a real backend. Document state is
/// persisted to local storage so it survives app restarts during testing.
class MockInterceptor extends Interceptor {
  static const _documentsPrefsKey = 'mock_citizen_documents';
  bool _loaded = false;

  Future<void> _ensureLoaded() async {
    if (_loaded) return;
    _loaded = true;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_documentsPrefsKey);
    if (raw == null) return;
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    _citizenDocuments
      ..clear()
      ..addAll(list);
  }

  Future<void> _persistDocuments() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_documentsPrefsKey, jsonEncode(_citizenDocuments));
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!kDebugMode) {
      handler.next(options);
      return;
    }

    await _ensureLoaded();

    final path = options.path.replaceFirst(options.baseUrl, '');
    final method = options.method.toUpperCase();
    final result = _mockResponse(method, path, options.data);

    if (result is _MockError) {
      debugPrint('[MOCK] $method $path → ${result.statusCode}');
      handler.reject(
        DioException(
          requestOptions: options,
          response: Response(
            requestOptions: options,
            statusCode: result.statusCode,
            data: result.body,
          ),
          type: DioExceptionType.badResponse,
        ),
        true,
      );
    } else if (result != null) {
      debugPrint('[MOCK] $method $path');
      handler.resolve(
        Response(requestOptions: options, statusCode: 200, data: result),
        true,
      );
    } else {
      handler.next(options);
    }
  }

  dynamic _mockResponse(String method, String path, dynamic body) {
    // ── Auth ──────────────────────────────────────────────────────────────
    if (path == '/auth/register' && method == 'POST') {
      return {'access': 'mock-token', 'user': _citizenProfile};
    }
    if (path == '/auth/login' && method == 'POST') {
      final email = (body is Map) ? body['email'] as String? : null;
      final password = (body is Map) ? body['password'] as String? : null;
      final role = (body is Map) ? body['role'] as String? : null;

      if (role == 'admin') {
        if ((email == 'admin@gmail.com' || email == 'admin@onecitizen.bd') &&
            password == 'admin123') {
          return {'access': 'mock-token', 'user': _adminProfile};
        }
      } else {
        if (email != null &&
            email.isNotEmpty &&
            password != null &&
            password.isNotEmpty) {
          return {'access': 'mock-token', 'user': _citizenProfile};
        }
      }
      return _MockError(401, {'detail': 'Invalid email or password.'});
    }
    if (path == '/auth/logout') {
      return {'success': true};
    }

    // ── Citizen profile ──────────────────────────────────────────────────
    if (path == ApiConfig.citizenProfile) {
      return _citizenProfile;
    }

    // ── Card types ───────────────────────────────────────────────────────
    if (path == ApiConfig.cardTypes) {
      return _cardTypes;
    }

    // ── Citizen eligibility ──────────────────────────────────────────────
    if (path == ApiConfig.citizenEligibility && method == 'POST') {
      return {
        'id': 'elig-${DateTime.now().millisecondsSinceEpoch}',
        'status': 'pending_review',
        'submitted_at': DateTime.now().toIso8601String(),
        'message':
            'Your eligibility request has been submitted. Admin will review and notify you shortly.',
      };
    }
    if (path == ApiConfig.citizenEligibility) {
      return _eligibilityResult;
    }

    // ── Citizen documents ────────────────────────────────────────────────
    if (path == ApiConfig.citizenDocuments) {
      if (method == 'POST') return _uploadDocument(body);
      return _citizenDocuments;
    }

    // ── Citizen applications ─────────────────────────────────────────────
    if (path == ApiConfig.citizenApplications) {
      if (method == 'POST') {
        final cardTypeId = body is Map
            ? body['card_type_id']?.toString()
            : null;
        return _mockApplication('app-new', 'submitted', cardTypeId: cardTypeId);
      }
      return _citizenApplications;
    }
    if (RegExp(r'^/citizen/applications/[^/]+$').hasMatch(path)) {
      final id = path.split('/').last;
      final statuses = {
        'app-1': 'submitted',
        'app-2': 'under_review',
        'app-3': 'approved',
        'app-4': 'rejected',
      };
      return _mockApplication(id, statuses[id] ?? 'submitted');
    }

    // ── Citizen distributions / notifications ───────────────────────────
    if (path == ApiConfig.citizenDistributions) {
      return _distributions;
    }
    if (path == ApiConfig.citizenNotifications) {
      return _notifications;
    }
    if (RegExp(r'^/citizen/notifications/[^/]+/read$').hasMatch(path)) {
      return {'success': true};
    }

    // ── Admin: applications ──────────────────────────────────────────────
    if (path == ApiConfig.adminApplications) {
      return _citizenApplications;
    }
    if (RegExp(r'^/admin/applications/[^/]+/approve$').hasMatch(path)) {
      return _mockApplication('app-1', 'approved');
    }
    if (RegExp(r'^/admin/applications/[^/]+/reject$').hasMatch(path)) {
      return _mockApplication('app-1', 'rejected');
    }
    if (RegExp(r'^/admin/applications/[^/]+$').hasMatch(path)) {
      final id = path.split('/').last;
      return _mockApplication(id, 'under_review');
    }

    // ── Admin: documents ──────────────────────────────────────────────────
    if (path == ApiConfig.adminDocuments) {
      return _citizenDocuments;
    }
    if (RegExp(r'^/admin/documents/[^/]+/validate$').hasMatch(path)) {
      final id = path.split('/')[3];
      final isValid = (body is Map) ? body['is_valid'] as bool? : true;
      final remark = (body is Map) ? body['remark'] as String? : null;
      final index = _citizenDocuments.indexWhere((d) => d['id'] == id);
      if (index == -1) return _citizenDocuments.first;
      _citizenDocuments[index] = {
        ..._citizenDocuments[index],
        'is_valid': isValid,
        'remark': remark,
      };
      _persistDocuments();
      return _citizenDocuments[index];
    }

    // ── Admin: distributions ─────────────────────────────────────────────
    if (path == ApiConfig.adminDistributions) {
      if (method == 'POST') return _distributions.first;
      return _distributions;
    }

    // ── Admin: citizens ───────────────────────────────────────────────────
    if (path == ApiConfig.adminCitizens) {
      return _citizens;
    }
    if (RegExp(r'^/admin/citizens/[^/]+/deactivate$').hasMatch(path)) {
      return {'success': true};
    }
    if (RegExp(r'^/admin/citizens/[^/]+$').hasMatch(path)) {
      return _citizenProfile;
    }

    // ── Admin: analytics ──────────────────────────────────────────────────
    if (path == ApiConfig.adminAnalytics) {
      return _analytics;
    }

    return null;
  }

  Map<String, dynamic> _uploadDocument(dynamic body) {
    final docType = body is FormData
        ? body.fields
              .firstWhere(
                (e) => e.key == 'doc_type',
                orElse: () => const MapEntry('doc_type', ''),
              )
              .value
        : '';
    final index = _citizenDocuments.indexWhere((d) => d['doc_type'] == docType);
    final newDoc = {
      'id': index >= 0
          ? _citizenDocuments[index]['id']
          : 'doc-${DateTime.now().millisecondsSinceEpoch}',
      'citizen_id': 'dev-citizen',
      'doc_type': docType,
      'file_url': 'https://placehold.co/400x300.png',
      'is_valid': null,
      'remark': null,
      'uploaded_at': DateTime.now().toIso8601String(),
      'citizen_name': 'Tanvirul Islam',
    };
    if (index >= 0) {
      _citizenDocuments[index] = newDoc;
    } else {
      _citizenDocuments.add(newDoc);
    }
    _persistDocuments();
    return newDoc;
  }

  // ── Mock data ────────────────────────────────────────────────────────────

  static const _citizenProfile = {
    'id': 'dev-citizen',
    'email': 'citizen@onecitizen.bd',
    'username': 'tanvirul',
    'nid': '1234567890',
    'first_name': 'Tanvirul',
    'last_name': 'Islam',
    'phone': '+8801700000001',
    'date_of_birth': '1995-05-10',
    'gender': 'male',
    'address': '123 Gulshan Ave, Dhaka 1212',
    'occupation': 'farmer',
    'income': 10000,
    'land_acres': 0.4,
    'ssc_gpa': 5.0,
    'hsc_gpa': 5.0,
    'role': 'citizen',
    'verified': true,
    'is_active': true,
    'profile_picture': null,
  };

  static const _adminProfile = {
    'id': 'dev-admin',
    'email': 'admin@onecitizen.bd',
    'first_name': 'System',
    'last_name': 'Admin',
    'role': 'admin',
    'is_active': true,
  };

  static const _cardTypes = [
    {
      'id': 'ct-farmer',
      'code': 'farmer',
      'name': 'Farmer Card',
      'eligibility_criteria':
          'Must be a registered farmer with a valid certificate from the local ward/union authority.',
      'required_documents': [
        'nid_copy',
        'agricultural_certificate',
        'ward_union_certificate',
      ],
    },
    {
      'id': 'ct-family',
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
    {
      'id': 'ct-education',
      'code': 'education',
      'name': 'Education Card',
      'eligibility_criteria':
          'Must have achieved GPA 5.00 in both SSC and HSC examinations.',
      'required_documents': ['nid_copy', 'ssc_marksheet', 'hsc_marksheet'],
    },
    {
      'id': 'ct-worker',
      'code': 'worker',
      'name': 'Worker Card',
      'eligibility_criteria':
          'Must be a low-income registered worker with employment or labor registration proof.',
      'required_documents': [
        'nid_copy',
        'worker_certificate',
        'labor_registration',
        'income_certificate',
      ],
    },
  ];

  static final _eligibilityResult = {
    'results': [
      {
        'card_type': _cardTypes[0],
        'eligible': true,
        'reason': 'Valid ward/union farmer certificate on file.',
      },
      {
        'card_type': _cardTypes[1],
        'eligible': true,
        'reason': 'Land holding and income are within the allowed limits.',
      },
      {
        'card_type': _cardTypes[2],
        'eligible': true,
        'reason': 'GPA 5.00 achieved in both SSC and HSC.',
      },
      {
        'card_type': _cardTypes[3],
        'eligible': true,
        'reason': 'Worker certificate and labor registration are available.',
      },
    ],
  };

  final List<Map<String, dynamic>> _citizenDocuments = [
    {
      'id': 'doc-1',
      'citizen_id': 'dev-citizen',
      'doc_type': 'nid_copy',
      'file_url': 'https://placehold.co/400x300.png',
      'is_valid': true,
      'remark': null,
      'uploaded_at': '2025-06-01T08:00:00Z',
      'citizen_name': 'Tanvirul Islam',
    },
    {
      'id': 'doc-2',
      'citizen_id': 'dev-citizen',
      'doc_type': 'income_certificate',
      'file_url': 'https://placehold.co/400x300.png',
      'is_valid': null,
      'remark': null,
      'uploaded_at': '2025-06-01T08:05:00Z',
      'citizen_name': 'Tanvirul Islam',
    },
    {
      'id': 'doc-3',
      'citizen_id': 'dev-citizen',
      'doc_type': 'ward_union_certificate',
      'file_url': 'https://placehold.co/400x300.png',
      'is_valid': false,
      'remark': 'Certificate is expired, please re-upload.',
      'uploaded_at': '2025-06-01T08:10:00Z',
      'citizen_name': 'Tanvirul Islam',
    },
  ];

  Map<String, dynamic> _mockApplication(
    String id,
    String status, {
    String? cardTypeId,
  }) {
    final cardType = _cardTypeById(cardTypeId) ?? _cardTypes[0];
    return {
      'id': id,
      'card_type_id': cardType['id'],
      'card_type_name': cardType['name'],
      'applicant_name': 'Tanvirul Islam',
      'applicant_nid': '1234567890',
      'applicant_email': 'citizen@onecitizen.bd',
      'status': status,
      'submitted_at': '2025-06-01T08:00:00Z',
      'updated_at': '2025-06-10T12:00:00Z',
      'admin_remark': status == 'rejected'
          ? 'Documents were incomplete.'
          : null,
    };
  }

  Map<String, dynamic>? _cardTypeById(String? cardTypeId) {
    if (cardTypeId == null || cardTypeId.isEmpty) return null;
    for (final cardType in _cardTypes) {
      if (cardType['id'] == cardTypeId) return cardType;
    }
    return null;
  }

  List<Map<String, dynamic>> get _citizenApplications => [
    _mockApplication('app-1', 'submitted'),
    _mockApplication('app-2', 'under_review', cardTypeId: 'ct-family'),
    _mockApplication('app-3', 'approved', cardTypeId: 'ct-education'),
    _mockApplication('app-4', 'rejected', cardTypeId: 'ct-worker'),
  ];

  static const _distributions = [
    {
      'id': 'dist-1',
      'app_id': 'app-3',
      'method': 'online',
      'amount': 5000,
      'dist_date': '2025-06-15T10:00:00Z',
      'note': 'Disbursed via bKash.',
      'card_type_name': 'Farmer Card',
      'citizen_name': 'Tanvirul Islam',
    },
  ];

  static const _notifications = [
    {
      'id': 'notif-1',
      'message': 'Your Farmer Card application has been approved.',
      'created_at': '2025-06-10T12:00:00Z',
      'is_read': false,
    },
    {
      'id': 'notif-2',
      'message':
          'Document "Ward/Union Authority Certificate" was marked invalid. Please re-upload.',
      'created_at': '2025-06-08T09:30:00Z',
      'is_read': false,
    },
    {
      'id': 'notif-3',
      'message': 'BDT 5,000 has been disbursed to your account via bKash.',
      'created_at': '2025-06-15T10:00:00Z',
      'is_read': true,
    },
  ];

  List<Map<String, dynamic>> get _citizens => List.generate(
    8,
    (i) => {
      'id': 'citizen-$i',
      'email': 'citizen$i@onecitizen.bd',
      'first_name': [
        'Rahim',
        'Karim',
        'Nasrin',
        'Jahangir',
        'Fatema',
        'Ariful',
        'Shamima',
        'Rafiqul',
      ][i],
      'last_name': 'Uddin',
      'nid': '12345678${90 + i}',
      'phone': '+880170000${1000 + i}',
      'role': 'citizen',
      'is_active': i != 5,
      'verified': true,
    },
  );

  static const _analytics = {
    'total_applications': 124,
    'applications_by_card_type': {
      'Farmer Card': 52,
      'Family Card': 41,
      'Education Card': 31,
    },
    'approved': 78,
    'rejected': 14,
    'pending_review': 32,
    'pending_document_reviews': 9,
    'total_disbursed': 312000,
  };
}

class _MockError {
  const _MockError(this.statusCode, this.body);
  final int statusCode;
  final Map<String, dynamic> body;
}
