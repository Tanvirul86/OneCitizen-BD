import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:onecitizen/config/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Frontend-only workflow store. It starts empty and persists only records
/// created through the app, so citizen and admin screens share the same state.
class LocalWorkflowInterceptor extends Interceptor {
  static const _stateKey = 'onecitizen_local_workflow_v1';
  String? _activeUserId;
  final Map<String, Map<String, dynamic>> _users = {};
  final Map<String, String> _passwords = {};
  final List<Map<String, dynamic>> _applications = [];
  final List<Map<String, dynamic>> _documents = [];
  final List<Map<String, dynamic>> _distributions = [];
  final List<Map<String, dynamic>> _citizenNotifications = [];
  final List<Map<String, dynamic>> _adminNotifications = [];

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    await _load();
    final result = await _handle(
      options.method.toUpperCase(),
      options.path,
      options.data,
      options.queryParameters,
    );
    if (result is _LocalError) {
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
      return;
    }
    handler.resolve(Response(requestOptions: options, statusCode: 200, data: result), true);
  }

  // Re-synced from storage before every request (not just once per process)
  // so that separate app instances/tabs sharing the same persisted store —
  // e.g. a citizen uploading a document and an admin reviewing it — see each
  // other's writes instead of freezing at whatever was on disk at first load.
  Future<void> _load() async {
    final raw = (await SharedPreferences.getInstance()).getString(_stateKey);
    if (raw == null) return;
    final state = jsonDecode(raw) as Map<String, dynamic>;
    _activeUserId = state['active_user_id']?.toString();
    _users.clear();
    _restoreMap(_users, state['users']);
    _passwords.clear();
    _restoreStringMap(_passwords, state['passwords']);
    _applications.clear();
    _restoreList(_applications, state['applications']);
    _documents.clear();
    _restoreList(_documents, state['documents']);
    _distributions.clear();
    _restoreList(_distributions, state['distributions']);
    _citizenNotifications.clear();
    _restoreList(_citizenNotifications, state['citizen_notifications']);
    _adminNotifications.clear();
    _restoreList(_adminNotifications, state['admin_notifications']);
  }

  void _restoreMap(Map<String, Map<String, dynamic>> target, dynamic raw) {
    if (raw is! Map) return;
    target.addAll(raw.map((key, value) => MapEntry(key.toString(), Map<String, dynamic>.from(value as Map))));
  }

  void _restoreStringMap(Map<String, String> target, dynamic raw) {
    if (raw is! Map) return;
    target.addAll(raw.map((key, value) => MapEntry(key.toString(), value.toString())));
  }

  void _restoreList(List<Map<String, dynamic>> target, dynamic raw) {
    if (raw is List) target.addAll(raw.map((item) => Map<String, dynamic>.from(item as Map)));
  }

  Future<void> _save() async {
    await (await SharedPreferences.getInstance()).setString(_stateKey, jsonEncode({
      'active_user_id': _activeUserId,
      'users': _users,
      'passwords': _passwords,
      'applications': _applications,
      'documents': _documents,
      'distributions': _distributions,
      'citizen_notifications': _citizenNotifications,
      'admin_notifications': _adminNotifications,
    }));
  }

  Future<dynamic> _handle(
    String method,
    String path,
    dynamic body,
    Map<String, dynamic> query,
  ) async {
    if (path == ApiConfig.register && method == 'POST') return _register(body);
    if (path == ApiConfig.login && method == 'POST') return _login(body);
    if (path == ApiConfig.logout) {
      _activeUserId = null;
      await _save();
      return {'success': true};
    }

    if (path == ApiConfig.cardTypes) return _cardTypes;
    if (path == ApiConfig.citizenProfile) return _profile(method, body);
    if (path == ApiConfig.citizenDocuments) return _citizenDocuments(method, body);
    if (path == ApiConfig.citizenApplications) return _citizenApplications(method, body);
    if (path == ApiConfig.citizenDistributions) return _owned(_distributions);
    if (path == ApiConfig.citizenNotifications) return _owned(_citizenNotifications);
    if (RegExp(r'^/citizen/notifications/[^/]+/read$').hasMatch(path)) return _markRead(_citizenNotifications, path);
    if (RegExp(r'^/citizen/applications/[^/]+$').hasMatch(path)) return _ownedApplication(path.split('/').last);

    if (path == ApiConfig.adminApplications) return _adminApplications(query);
    if (RegExp(r'^/admin/applications/[^/]+/approve$').hasMatch(path)) return _setApplicationStatus(path.split('/')[3], 'approved');
    if (RegExp(r'^/admin/applications/[^/]+/reject$').hasMatch(path)) return _setApplicationStatus(path.split('/')[3], 'rejected', remark: body is Map ? body['reason']?.toString() : null);
    if (RegExp(r'^/admin/applications/[^/]+$').hasMatch(path)) return _findById(_applications, path.split('/').last);
    if (path == ApiConfig.adminDocuments) return _filterDocuments(query);
    if (RegExp(r'^/admin/documents/[^/]+/validate$').hasMatch(path)) return _validateDocument(path.split('/')[3], body);
    if (path == ApiConfig.adminDistributions) return method == 'POST' ? _createDistribution(body) : _distributions;
    if (path == ApiConfig.adminCitizens) return _users.values.where((user) => user['role'] == 'citizen').toList();
    if (RegExp(r'^/admin/citizens/[^/]+/(activate|deactivate|freeze|unfreeze)$').hasMatch(path)) return _updateCitizen(path);
    if (RegExp(r'^/admin/citizens/[^/]+$').hasMatch(path)) {
      return _users[path.split('/').last] ?? _LocalError(404, {'detail': 'Citizen not found.'});
    }
    if (path == ApiConfig.adminAnalytics) return _analytics();
    if (path == ApiConfig.adminNotifications) return _adminNotifications;
    if (RegExp(r'^/admin/notifications/[^/]+/read$').hasMatch(path)) return _markRead(_adminNotifications, path);
    return _LocalError(404, {'detail': 'Frontend workflow endpoint not found.'});
  }

  Future<dynamic> _register(dynamic body) async {
    final data = Map<String, dynamic>.from(body as Map? ?? {});
    final email = data['email']?.toString().trim().toLowerCase() ?? '';
    final password = data['password']?.toString() ?? '';
    if (email.isEmpty || password.isEmpty) return _LocalError(400, {'detail': 'Email and password are required.'});
    if (_users.values.any((user) => user['email'] == email)) return _LocalError(400, {'detail': 'An account with this email already exists.'});
    final id = _newId('citizen');
    _users[id] = {
      'id': id, 'email': email, 'first_name': data['first_name'], 'last_name': data['last_name'],
      'phone': data['phone'], 'nid': data['nid'], 'role': 'citizen', 'is_active': true,
      'is_frozen': false, 'verified': false,
    };
    _passwords[id] = password;
    await _save();
    return {'success': true};
  }

  Future<dynamic> _login(dynamic body) async {
    final data = Map<String, dynamic>.from(body as Map? ?? {});
    final email = data['email']?.toString().trim().toLowerCase() ?? '';
    final password = data['password']?.toString() ?? '';
    final role = data['role']?.toString() ?? 'citizen';
    var user = _users.values.where((candidate) => candidate['email'] == email && candidate['role'] == role).cast<Map<String, dynamic>?>().firstWhere((candidate) => candidate != null, orElse: () => null);
    if (role == 'admin' && user == null) {
      if (!_adminEmails.contains(email) || password != _adminPassword) {
        return _LocalError(401, {'detail': 'Invalid email or password.'});
      }
      user = {
        'id': _adminId(email),
        'email': email,
        'first_name': 'System',
        'last_name': 'Admin',
        'role': 'admin',
        'is_active': true,
      };
      _users[_adminId(email)] = user;
      _passwords[_adminId(email)] = _adminPassword;
    }
    if (user == null || _passwords[user['id']] != password) return _LocalError(401, {'detail': 'Invalid email or password.'});
    _activeUserId = user['id']?.toString();
    await _save();
    return {'access': 'local-${_activeUserId!}', 'user': user};
  }

  Future<dynamic> _profile(String method, dynamic body) async {
    final user = _activeUser();
    if (user == null) return _LocalError(401, {'detail': 'Sign in required.'});
    if (method == 'PATCH' && body is Map) {
      _users[user['id'].toString()] = {...user, ...Map<String, dynamic>.from(body)};
      await _save();
    }
    return _users[user['id'].toString()];
  }

  Future<dynamic> _citizenDocuments(String method, dynamic body) async {
    final user = _activeCitizen();
    if (user is _LocalError) return user;
    if (method != 'POST') return _owned(_documents);
    final docType = _formField(body, 'doc_type') ?? '';
    final applicationId = _formField(body, 'application_id');
    final existing = _documents.indexWhere(
      (doc) =>
          doc['citizen_id'] == user['id'] &&
          doc['doc_type'] == docType &&
          doc['application_id'] == applicationId,
    );
    final record = {
      'id': existing >= 0 ? _documents[existing]['id'] : _newId('document'),
      'citizen_id': user['id'],
      'citizen_name': _name(user),
      'doc_type': docType,
      'application_id': applicationId,
      'file_url': '',
      'is_valid': null,
      'remark': null,
      'uploaded_at': DateTime.now().toIso8601String(),
    };
    if (existing >= 0) {
      _documents[existing] = record;
    } else {
      _documents.add(record);
    }
    if (applicationId != null) {
      final appIndex = _applications.indexWhere((app) => app['id'] == applicationId);
      if (appIndex >= 0) {
        _applications[appIndex] = {
          ..._applications[appIndex],
          'status': 'under_review',
          'admin_remark': null,
          'updated_at': DateTime.now().toIso8601String(),
        };
      }
    }
    await _save();
    return record;
  }

  Future<dynamic> _citizenApplications(String method, dynamic body) async {
    final user = _activeCitizen();
    if (user is _LocalError) return user;
    if (method != 'POST') return _owned(_applications);
    final data = Map<String, dynamic>.from(body as Map? ?? {});
    final card = _cardTypes.where((item) => item['id'] == data['card_type_id']?.toString()).cast<Map<String, dynamic>?>().firstWhere((item) => item != null, orElse: () => null);
    if (card == null) return _LocalError(400, {'detail': 'Choose a card type.'});
    final app = {'id': _newId('application'), 'card_type_id': card['id'], 'card_type_name': card['name'], 'applicant_id': user['id'], 'applicant_name': _name(user), 'applicant_email': user['email'], 'status': 'submitted', 'submitted_at': DateTime.now().toIso8601String(), 'updated_at': DateTime.now().toIso8601String(), 'application_data': data['application_data'] ?? {}};
    _applications.insert(0, app);
    final requiredDocuments = (card['required_documents'] as List)
        .map((document) => document.toString())
        .toSet();
    for (var index = 0; index < _documents.length; index++) {
      final document = _documents[index];
      if (document['citizen_id'] == user['id'] &&
          document['application_id'] == null &&
          requiredDocuments.contains(document['doc_type'])) {
        _documents[index] = {
          ...document,
          'application_id': app['id'],
          'card_type_id': card['id'],
        };
      }
    }
    _adminNotifications.insert(0, _notification('New ${card['name']} request received from ${_name(user)}.'));
    await _save();
    return app;
  }

  dynamic _ownedApplication(String id) {
    final app = _applications.where((item) => item['id'] == id && item['applicant_id'] == _activeUserId).cast<Map<String, dynamic>?>().firstWhere((item) => item != null, orElse: () => null);
    return app ?? _LocalError(404, {'detail': 'Application not found.'});
  }

  List<Map<String, dynamic>> _owned(List<Map<String, dynamic>> source) => source.where((item) => item['citizen_id'] == _activeUserId || item['applicant_id'] == _activeUserId).toList();

  List<Map<String, dynamic>> _adminApplications(Map<String, dynamic> query) => _applications.where((app) => (query['status'] == null || app['status'] == query['status']) && (query['card_type_id'] == null || app['card_type_id'] == query['card_type_id'])).toList();

  dynamic _setApplicationStatus(String id, String status, {String? remark}) async {
    final index = _applications.indexWhere((app) => app['id'] == id);
    if (index < 0) return _LocalError(404, {'detail': 'Application not found.'});
    final updated = {..._applications[index], 'status': status, 'admin_remark': remark, 'updated_at': DateTime.now().toIso8601String()};
    _applications[index] = updated;
    _citizenNotifications.insert(0, {..._notification('Your ${updated['card_type_name']} request was $status.'), 'citizen_id': updated['applicant_id']});
    await _save();
    return updated;
  }

  List<Map<String, dynamic>> _filterDocuments(Map<String, dynamic> query) =>
      _documents
          .where(
            (doc) =>
                doc['application_id'] != null &&
                (query['citizen_id'] == null ||
                    doc['citizen_id'] == query['citizen_id']) &&
                (query['citizen_email'] == null ||
                    _users[doc['citizen_id']]?['email'] ==
                        query['citizen_email']),
          )
          .toList();

  dynamic _validateDocument(String id, dynamic body) async {
    final index = _documents.indexWhere((doc) => doc['id'] == id);
    if (index < 0) return _LocalError(404, {'detail': 'Document not found.'});
    final isValid = body is Map ? body['is_valid'] == true : true;
    final remark = body is Map ? body['remark']?.toString() : null;
    _documents[index] = {
      ..._documents[index],
      'is_valid': isValid,
      'remark': remark,
    };
    if (!isValid) {
      final applicationId = _documents[index]['application_id']?.toString();
      final appIndex = _applications.indexWhere((app) => app['id'] == applicationId);
      if (appIndex >= 0) {
        final app = {
          ..._applications[appIndex],
          'status': 'rejected',
          'admin_remark': remark ?? 'Please re-upload ${_documents[index]['doc_type']}.',
          'updated_at': DateTime.now().toIso8601String(),
        };
        _applications[appIndex] = app;
        _citizenNotifications.insert(0, {
          ..._notification(
            '${_documents[index]['doc_type']} was rejected. Please re-upload it for your ${app['card_type_name']} request.',
          ),
          'citizen_id': app['applicant_id'],
        });
      }
    }
    await _save();
    return _documents[index];
  }

  dynamic _createDistribution(dynamic body) async {
    final data = Map<String, dynamic>.from(body as Map? ?? {});
    final app = _findById(_applications, data['app_id']?.toString());
    if (app is _LocalError) return app;
    final distribution = {'id': _newId('distribution'), 'app_id': app['id'], 'method': data['method'] ?? 'online', 'amount': data['amount'] ?? 0, 'dist_date': DateTime.now().toIso8601String(), 'note': data['note'], 'card_type_name': app['card_type_name'], 'citizen_name': app['applicant_name'], 'citizen_id': app['applicant_id']};
    _distributions.insert(0, distribution);
    _citizenNotifications.insert(0, {..._notification('A fund distribution has been recorded for your ${app['card_type_name']} request.'), 'citizen_id': app['applicant_id']});
    await _save();
    return distribution;
  }

  dynamic _updateCitizen(String path) async {
    final parts = path.split('/');
    final id = parts[3];
    final action = parts[4];
    final user = _users[id];
    if (user == null) return _LocalError(404, {'detail': 'Citizen not found.'});
    _users[id] = {...user, if (action == 'freeze') 'is_frozen': true, if (action == 'unfreeze') 'is_frozen': false, if (action == 'deactivate') 'is_active': false, if (action == 'activate') 'is_active': true};
    await _save();
    return {'success': true};
  }

  dynamic _analytics() => {'total_applications': _applications.length, 'approved': _applications.where((app) => app['status'] == 'approved').length, 'rejected': _applications.where((app) => app['status'] == 'rejected').length, 'pending_review': _applications.where((app) => app['status'] == 'submitted' || app['status'] == 'under_review').length, 'pending_document_reviews': _documents.where((doc) => doc['application_id'] != null && doc['is_valid'] == null).length, 'total_disbursed': _distributions.fold<num>(0, (sum, item) => sum + ((item['amount'] as num?) ?? 0)), 'applications_by_card_type': <String, int>{}};

  dynamic _markRead(List<Map<String, dynamic>> source, String path) async {
    final id = path.split('/')[3];
    final index = source.indexWhere((item) => item['id'] == id);
    if (index >= 0) source[index] = {...source[index], 'is_read': true};
    await _save();
    return {'success': true};
  }

  dynamic _findById(List<Map<String, dynamic>> source, String? id) {
    for (final item in source) {
      if (item['id'] == id) return item;
    }
    return _LocalError(404, {'detail': 'Record not found.'});
  }
  Map<String, dynamic>? _activeUser() => _activeUserId == null ? null : _users[_activeUserId];
  String? _formField(dynamic body, String key) {
    if (body is! FormData) return null;
    for (final field in body.fields) {
      if (field.key == key) return field.value;
    }
    return null;
  }
  dynamic _activeCitizen() => _activeUser()?['role'] == 'citizen' ? _activeUser()! : _LocalError(401, {'detail': 'Citizen sign in required.'});
  String _newId(String type) => '$type-${DateTime.now().microsecondsSinceEpoch}';
  String _name(Map<String, dynamic> user) => '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'.trim().isEmpty ? user['email'].toString() : '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'.trim();
  Map<String, dynamic> _notification(String message) => {'id': _newId('notification'), 'message': message, 'created_at': DateTime.now().toIso8601String(), 'is_read': false};

  static const _cardTypes = [
    {
      'id': 'farmer', 'code': 'farmer', 'name': 'Farmer Card',
      'eligibility_criteria': 'Submit your documents for administrative review.',
      'required_documents': ['nid_copy', 'union_paurosova_certificate', 'recent_photo', 'agricultural_certificate'],
      'application_fields': [
        {'key': 'first_name', 'label': 'First name', 'required': true},
        {'key': 'last_name', 'label': 'Last name', 'required': true},
        {'key': 'nid_card_number', 'label': 'NID card number', 'required': true, 'input_type': 'number'},
        {'key': 'date_of_birth', 'label': 'Date of birth', 'hint': 'DD/MM/YYYY', 'required': true, 'input_type': 'date'},
        {'key': 'phone_number', 'label': 'Phone number linked with own NID', 'required': true, 'input_type': 'phone'},
        {'key': 'mobile_wallet', 'label': 'Mobile financial service', 'required': true, 'options': ['bKash', 'Nagad']},
        {'key': 'cultivated_land_amount', 'label': 'Cultivated land amount', 'required': true, 'input_type': 'number'},
        {'key': 'land_unit', 'label': 'Land measuring unit', 'required': true, 'options': ['Decimal', 'Katha', 'Bigha', 'Acre']},
        {'key': 'village_road', 'label': 'Village/Road/House', 'required': true},
      ],
    },
    {
      'id': 'family', 'code': 'family', 'name': 'Family Card',
      'eligibility_criteria': 'Submit your documents for administrative review.',
      'required_documents': ['nid_copy', 'union_paurosova_certificate', 'recent_photo', 'income_certificate'],
      'application_fields': [
        {'key': 'first_name', 'label': 'First name', 'required': true},
        {'key': 'last_name', 'label': 'Last name', 'required': true},
        {'key': 'nid_card_number', 'label': 'NID card number', 'required': true, 'input_type': 'number'},
        {'key': 'date_of_birth', 'label': 'Date of birth', 'hint': 'DD/MM/YYYY', 'required': true, 'input_type': 'date'},
        {'key': 'phone_number', 'label': 'Phone number linked with own NID', 'required': true, 'input_type': 'phone'},
        {'key': 'mobile_wallet', 'label': 'Mobile financial service', 'required': true, 'options': ['bKash', 'Nagad']},
        {'key': 'family_members', 'label': 'Number of family members', 'required': true, 'input_type': 'number'},
        {'key': 'monthly_income', 'label': 'Monthly household income', 'required': true, 'input_type': 'number'},
        {'key': 'dependents', 'label': 'Number of dependents', 'required': true, 'input_type': 'number'},
        {'key': 'village_road', 'label': 'Village/Road/House', 'required': true},
      ],
    },
    {
      'id': 'education', 'code': 'education', 'name': 'Education Card',
      'eligibility_criteria': 'Submit your documents for administrative review.',
      'required_documents': ['nid_birth_certificate', 'ssc_registration_card', 'ssc_admit_card', 'ssc_certificate', 'hsc_registration_card', 'hsc_admit_card', 'hsc_certificate', 'recent_photo'],
      'application_fields': [
        {'key': 'student_first_name', 'label': 'Student first name', 'required': true},
        {'key': 'student_last_name', 'label': 'Student last name', 'required': true},
        {'key': 'father_name', 'label': 'Father name', 'required': true},
        {'key': 'mother_name', 'label': 'Mother name', 'required': true},
        {'key': 'date_of_birth', 'label': 'Date of birth', 'hint': 'DD/MM/YYYY', 'required': true, 'input_type': 'date'},
        {'key': 'nid_birth_certificate_number', 'label': 'NID/Birth certificate number', 'required': true, 'input_type': 'number'},
        {'key': 'ssc_institute_eiin', 'label': 'SSC institute EIIN number', 'required': true, 'input_type': 'number'},
        {'key': 'ssc_registration_number', 'label': 'SSC registration number', 'required': true, 'input_type': 'number'},
        {'key': 'ssc_roll_number', 'label': 'SSC roll number', 'required': true, 'input_type': 'number'},
        {'key': 'ssc_board', 'label': 'SSC board', 'required': true, 'options': ['Dhaka', 'Chattogram', 'Rajshahi', 'Cumilla', 'Jashore', 'Barishal', 'Sylhet', 'Dinajpur', 'Mymensingh', 'Madrasah', 'Technical']},
        {'key': 'ssc_passing_year', 'label': 'SSC passing year', 'required': true, 'input_type': 'number'},
        {'key': 'hsc_institute_eiin', 'label': 'HSC institute EIIN number', 'required': true, 'input_type': 'number'},
        {'key': 'hsc_registration_number', 'label': 'HSC registration number', 'required': true, 'input_type': 'number'},
        {'key': 'hsc_roll_number', 'label': 'HSC roll number', 'required': true, 'input_type': 'number'},
        {'key': 'hsc_board', 'label': 'HSC board', 'required': true, 'options': ['Dhaka', 'Chattogram', 'Rajshahi', 'Cumilla', 'Jashore', 'Barishal', 'Sylhet', 'Dinajpur', 'Mymensingh', 'Madrasah', 'Technical']},
        {'key': 'hsc_passing_year', 'label': 'HSC passing year', 'required': true, 'input_type': 'number'},
      ],
    },
  ];

  String _adminId(String email) => 'local-admin-$email';
  static const _adminEmails = {'admin@gmail.com', 'admin@onecitizen.bd'};
  static const _adminPassword = 'admin123';
}

class _LocalError {
  const _LocalError(this.statusCode, this.body);
  final int statusCode;
  final Map<String, dynamic> body;
}
