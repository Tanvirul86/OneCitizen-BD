import 'package:onecitizen/config/api_config.dart';
import 'package:onecitizen/models/application.dart';
import 'package:onecitizen/models/distribution.dart';
import 'package:onecitizen/models/document.dart';
import 'package:onecitizen/models/notification.dart';
import 'package:onecitizen/models/user.dart';
import 'package:onecitizen/services/api_client.dart';

class AdminService {
  AdminService({required ApiClient apiClient}) : _apiClient = apiClient;
  final ApiClient _apiClient;

  // ── Applications ─────────────────────────────────────────────────────────
  Future<List<Application>> getApplications({
    String? cardTypeId,
    ApplicationStatus? status,
  }) async {
    final response = await _apiClient.dio.get(
      ApiConfig.adminApplications,
      queryParameters: {
        if (cardTypeId != null && cardTypeId.isNotEmpty) 'card_type_id': cardTypeId,
        if (status != null) 'status': applicationStatusToString(status),
      },
    );
    final list = response.data as List<dynamic>;
    return list
        .map((e) => Application.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Application> getApplication(String id) async {
    final response = await _apiClient.dio.get('${ApiConfig.adminApplications}/$id');
    return Application.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Application> approveApplication(String id) async {
    final response = await _apiClient.dio
        .patch('${ApiConfig.adminApplications}/$id/approve');
    return Application.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Application> rejectApplication(String id, {required String reason}) async {
    final response = await _apiClient.dio.patch(
      '${ApiConfig.adminApplications}/$id/reject',
      data: {'reason': reason},
    );
    return Application.fromJson(response.data as Map<String, dynamic>);
  }

  // ── Document validation ─────────────────────────────────────────────────
  Future<List<CitizenDocument>> getPendingDocuments() async {
    final response = await _apiClient.dio.get(ApiConfig.adminDocuments);
    final list = response.data as List<dynamic>;
    return list
        .map((e) => CitizenDocument.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<CitizenDocument> validateDocument(
    String id, {
    required bool isValid,
    String? remark,
  }) async {
    final response = await _apiClient.dio.patch(
      '${ApiConfig.adminDocuments}/$id/validate',
      data: {'is_valid': isValid, 'remark': ?remark},
    );
    return CitizenDocument.fromJson(response.data as Map<String, dynamic>);
  }

  // ── Fund distribution ────────────────────────────────────────────────────
  Future<Distribution> createDistribution({
    required String applicationId,
    required DistributionMethod method,
    required double amount,
    String? note,
  }) async {
    final response = await _apiClient.dio.post(
      ApiConfig.adminDistributions,
      data: {
        'app_id': applicationId,
        'method': distributionMethodToString(method),
        'amount': amount,
        'note': ?note,
      },
    );
    return Distribution.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<Distribution>> getDistributions({
    String? cardTypeId,
    DistributionMethod? method,
  }) async {
    final response = await _apiClient.dio.get(
      ApiConfig.adminDistributions,
      queryParameters: {
        if (cardTypeId != null && cardTypeId.isNotEmpty) 'card_type_id': cardTypeId,
        if (method != null) 'method': distributionMethodToString(method),
      },
    );
    final list = response.data as List<dynamic>;
    return list
        .map((e) => Distribution.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Citizen accounts ──────────────────────────────────────────────────────
  Future<List<User>> getCitizens({String? search}) async {
    final response = await _apiClient.dio.get(
      ApiConfig.adminCitizens,
      queryParameters: {if (search != null && search.isNotEmpty) 'search': search},
    );
    final list = response.data as List<dynamic>;
    return list.map((e) => User.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<User> getCitizen(String id) async {
    final response = await _apiClient.dio.get('${ApiConfig.adminCitizens}/$id');
    return User.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deactivateCitizen(String id) async {
    await _apiClient.dio.patch('${ApiConfig.adminCitizens}/$id/deactivate');
  }

  // ── Analytics ────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getAnalytics() async {
    final response = await _apiClient.dio.get(ApiConfig.adminAnalytics);
    return response.data as Map<String, dynamic>;
  }
}

class AdminNotificationService {
  AdminNotificationService({required ApiClient apiClient}) : _apiClient = apiClient;
  final ApiClient _apiClient;

  Future<List<AppNotification>> getNotifications() async {
    final response = await _apiClient.dio.get(ApiConfig.adminNotifications);
    final list = response.data as List<dynamic>;
    return list
        .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> markAsRead(String id) async {
    await _apiClient.dio.patch('${ApiConfig.adminNotifications}/$id/read');
  }
}
