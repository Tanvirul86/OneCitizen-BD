import 'package:dio/dio.dart';
import 'package:onecitizen/config/api_config.dart';
import 'package:onecitizen/models/application.dart';
import 'package:onecitizen/models/card.dart';
import 'package:onecitizen/models/card_type.dart';
import 'package:onecitizen/models/complaint.dart';
import 'package:onecitizen/services/api_client.dart';

class CardService {
  CardService({required ApiClient apiClient}) : _apiClient = apiClient;
  final ApiClient _apiClient;

  Future<List<CitizenCard>> getMyCards() async {
    final response = await _apiClient.dio.get(ApiConfig.cards);
    final list = response.data as List<dynamic>;
    return list
        .map((e) => CitizenCard.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<CitizenCard> getCard(String id) async {
    final response = await _apiClient.dio.get('${ApiConfig.cards}$id/');
    return CitizenCard.fromJson(response.data as Map<String, dynamic>);
  }
}

class ApplicationService {
  ApplicationService({required ApiClient apiClient}) : _apiClient = apiClient;
  final ApiClient _apiClient;

  Future<List<Application>> getApplications() async {
    final response = await _apiClient.dio.get(ApiConfig.applications);
    final list = response.data as List<dynamic>;
    return list
        .map((e) => Application.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Application> getApplication(String id) async {
    final response = await _apiClient.dio.get('${ApiConfig.applications}$id/');
    return Application.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Application> submitApplication({
    required String cardTypeId,
    required Map<String, String> documentPaths,
  }) async {
    final formMap = <String, dynamic>{'card_type': cardTypeId};
    for (final entry in documentPaths.entries) {
      formMap[entry.key] = await MultipartFile.fromFile(entry.value);
    }
    final response = await _apiClient.dio.post(
      ApiConfig.applications,
      data: FormData.fromMap(formMap),
    );
    return Application.fromJson(response.data as Map<String, dynamic>);
  }
}

class EligibilityService {
  EligibilityService({required ApiClient apiClient}) : _apiClient = apiClient;
  final ApiClient _apiClient;

  Future<EligibilityResult> checkEligibility({
    required String occupation,
    required double income,
    required int age,
    double? landHolding,
  }) async {
    final response = await _apiClient.dio.post(
      ApiConfig.eligibilityCheck,
      data: {
        'occupation': occupation,
        'income': income,
        'age': age,
        if (landHolding != null) 'land_holding': landHolding,
      },
    );
    return EligibilityResult.fromJson(response.data as Map<String, dynamic>);
  }
}

class ComplaintService {
  ComplaintService({required ApiClient apiClient}) : _apiClient = apiClient;
  final ApiClient _apiClient;

  Future<List<Complaint>> getComplaints() async {
    final response = await _apiClient.dio.get(ApiConfig.complaints);
    final list = response.data as List<dynamic>;
    return list
        .map((e) => Complaint.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Complaint> submitComplaint({
    required String subject,
    required String description,
  }) async {
    final response = await _apiClient.dio.post(
      ApiConfig.complaints,
      data: {'subject': subject, 'description': description},
    );
    return Complaint.fromJson(response.data as Map<String, dynamic>);
  }
}

class CardTypeService {
  CardTypeService({required ApiClient apiClient}) : _apiClient = apiClient;
  final ApiClient _apiClient;

  Future<List<CardType>> getCardTypes() async {
    final response = await _apiClient.dio.get(ApiConfig.cardTypes);
    final list = response.data as List<dynamic>;
    return list.map((e) => CardType.fromJson(e as Map<String, dynamic>)).toList();
  }
}
