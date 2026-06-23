import 'package:onecitizen/config/api_config.dart';
import 'package:onecitizen/models/application.dart';
import 'package:onecitizen/models/complaint.dart';
import 'package:onecitizen/models/card_type.dart';
import 'package:onecitizen/models/user.dart';
import 'package:onecitizen/services/api_client.dart';

class OfficerService {
  OfficerService({required ApiClient apiClient}) : _apiClient = apiClient;
  final ApiClient _apiClient;

  Future<List<Application>> getPendingApplications({
    String? search,
    ApplicationStatus? status,
  }) async {
    final response = await _apiClient.dio.get(
      ApiConfig.officerApplications,
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
        if (status != null) 'status': _statusParam(status),
      },
    );
    final list = response.data as List<dynamic>;
    return list
        .map((e) => Application.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Application> getApplicationDetail(String id) async {
    final response =
        await _apiClient.dio.get('${ApiConfig.officerApplications}$id/');
    return Application.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Application> updateApplicationStatus({
    required String id,
    required ApplicationStatus status,
    String? remarks,
  }) async {
    final response = await _apiClient.dio.patch(
      '${ApiConfig.officerApplications}$id/',
      data: {
        'status': _statusParam(status),
        if (remarks != null) 'remarks': remarks,
      },
    );
    return Application.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> verifyCitizen({required String nid}) async {
    final response = await _apiClient.dio.post(
      ApiConfig.officerVerify,
      data: {'nid': nid},
    );
    return response.data as Map<String, dynamic>;
  }

  String _statusParam(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.submitted:
        return 'submitted';
      case ApplicationStatus.underReview:
        return 'under_review';
      case ApplicationStatus.approved:
        return 'approved';
      case ApplicationStatus.rejected:
        return 'rejected';
      case ApplicationStatus.documentRequested:
        return 'document_requested';
    }
  }
}

class AdminService {
  AdminService({required ApiClient apiClient}) : _apiClient = apiClient;
  final ApiClient _apiClient;

  Future<List<User>> getUsers() async {
    final response = await _apiClient.dio.get(ApiConfig.adminUsers);
    final list = response.data as List<dynamic>;
    return list.map((e) => User.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> suspendUser(String id) async {
    await _apiClient.dio.patch('${ApiConfig.adminUsers}$id/', data: {
      'is_active': false,
    });
  }

  Future<void> reactivateUser(String id) async {
    await _apiClient.dio.patch('${ApiConfig.adminUsers}$id/', data: {
      'is_active': true,
    });
  }

  Future<void> deleteUser(String id) async {
    await _apiClient.dio.delete('${ApiConfig.adminUsers}$id/');
  }

  Future<List<CardType>> getCardTypes() async {
    final response = await _apiClient.dio.get(ApiConfig.adminCardTypes);
    final list = response.data as List<dynamic>;
    return list.map((e) => CardType.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<CardType> createCardType(CardType cardType) async {
    final response = await _apiClient.dio.post(
      ApiConfig.adminCardTypes,
      data: cardType.toJson(),
    );
    return CardType.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteCardType(String id) async {
    await _apiClient.dio.delete('${ApiConfig.adminCardTypes}$id/');
  }

  Future<CardType> updateCardType(String id, CardType cardType) async {
    final response = await _apiClient.dio.patch(
      '${ApiConfig.adminCardTypes}$id/',
      data: cardType.toJson(),
    );
    return CardType.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<User>> getOfficers() async {
    final response = await _apiClient.dio.get(ApiConfig.adminOfficers);
    final list = response.data as List<dynamic>;
    return list.map((e) => User.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<User> createOfficer({
    required String phoneNumber,
    required String fullName,
  }) async {
    final response = await _apiClient.dio.post(
      ApiConfig.adminOfficers,
      data: {'phone_number': phoneNumber, 'full_name': fullName},
    );
    return User.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> removeOfficer(String id) async {
    await _apiClient.dio.delete('${ApiConfig.adminOfficers}$id/');
  }

  Future<List<Complaint>> getAllComplaints() async {
    final response = await _apiClient.dio.get(ApiConfig.adminComplaints);
    final list = response.data as List<dynamic>;
    return list
        .map((e) => Complaint.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Complaint> resolveComplaint({
    required String id,
    required String resolution,
  }) async {
    final response = await _apiClient.dio.patch(
      '${ApiConfig.adminComplaints}$id/',
      data: {'status': 'resolved', 'resolution': resolution},
    );
    return Complaint.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<Map<String, dynamic>>> getSystemLogs() async {
    final response = await _apiClient.dio.get(ApiConfig.adminLogs);
    return (response.data as List<dynamic>)
        .map((e) => e as Map<String, dynamic>)
        .toList();
  }
}
