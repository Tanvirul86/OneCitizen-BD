import 'package:dio/dio.dart';
import 'package:onecitizen/config/api_config.dart';
import 'package:onecitizen/models/application.dart';
import 'package:onecitizen/models/card_type.dart';
import 'package:onecitizen/models/distribution.dart';
import 'package:onecitizen/models/document.dart';
import 'package:onecitizen/models/notification.dart';
import 'package:onecitizen/services/api_client.dart';

class CardTypeService {
  CardTypeService({required ApiClient apiClient}) : _apiClient = apiClient;
  final ApiClient _apiClient;

  Future<List<CardType>> getCardTypes() async {
    final response = await _apiClient.dio.get(ApiConfig.cardTypes);
    final list = response.data as List<dynamic>;
    return list.map((e) => CardType.fromJson(e as Map<String, dynamic>)).toList();
  }
}

class EligibilityService {
  EligibilityService({required ApiClient apiClient}) : _apiClient = apiClient;
  final ApiClient _apiClient;

  Future<EligibilityResult> checkEligibility() async {
    final response = await _apiClient.dio.get(ApiConfig.citizenEligibility);
    return EligibilityResult.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> submitEligibilityRequest(Map<String, dynamic> data) async {
    final response = await _apiClient.dio.post(ApiConfig.citizenEligibility, data: data);
    return response.data as Map<String, dynamic>;
  }
}

class ApplicationService {
  ApplicationService({required ApiClient apiClient}) : _apiClient = apiClient;
  final ApiClient _apiClient;

  Future<List<Application>> getApplications() async {
    final response = await _apiClient.dio.get(ApiConfig.citizenApplications);
    final list = response.data as List<dynamic>;
    return list
        .map((e) => Application.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Application> getApplication(String id) async {
    final response =
        await _apiClient.dio.get('${ApiConfig.citizenApplications}/$id');
    return Application.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Application> submitApplication({required String cardTypeId}) async {
    final response = await _apiClient.dio.post(
      ApiConfig.citizenApplications,
      data: {'card_type_id': cardTypeId},
    );
    return Application.fromJson(response.data as Map<String, dynamic>);
  }
}

class DocumentService {
  DocumentService({required ApiClient apiClient}) : _apiClient = apiClient;
  final ApiClient _apiClient;

  Future<List<CitizenDocument>> getDocuments() async {
    final response = await _apiClient.dio.get(ApiConfig.citizenDocuments);
    final list = response.data as List<dynamic>;
    return list
        .map((e) => CitizenDocument.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<CitizenDocument> uploadDocument({
    required String docType,
    required String filePath,
  }) async {
    final formData = FormData.fromMap({
      'doc_type': docType,
      'file': await MultipartFile.fromFile(filePath),
    });
    final response = await _apiClient.dio.post(
      ApiConfig.citizenDocuments,
      data: formData,
    );
    return CitizenDocument.fromJson(response.data as Map<String, dynamic>);
  }
}

class DistributionService {
  DistributionService({required ApiClient apiClient}) : _apiClient = apiClient;
  final ApiClient _apiClient;

  Future<List<Distribution>> getDistributions() async {
    final response = await _apiClient.dio.get(ApiConfig.citizenDistributions);
    final list = response.data as List<dynamic>;
    return list
        .map((e) => Distribution.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

class NotificationService {
  NotificationService({required ApiClient apiClient}) : _apiClient = apiClient;
  final ApiClient _apiClient;

  Future<List<AppNotification>> getNotifications() async {
    final response = await _apiClient.dio.get(ApiConfig.citizenNotifications);
    final list = response.data as List<dynamic>;
    return list
        .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> markAsRead(String id) async {
    await _apiClient.dio.patch('${ApiConfig.citizenNotifications}/$id/read');
  }
}
