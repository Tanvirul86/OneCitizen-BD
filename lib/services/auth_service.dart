import 'package:onecitizen/config/api_config.dart';
import 'package:onecitizen/models/user.dart';
import 'package:onecitizen/services/api_client.dart';
import 'package:onecitizen/services/storage_service.dart';

class AuthService {
  AuthService({
    required ApiClient apiClient,
    required StorageService storageService,
  })  : _apiClient = apiClient,
        _storageService = storageService;

  final ApiClient _apiClient;
  final StorageService _storageService;

  /// Creates the account only — does not sign the user in. They must call
  /// [login] afterward with the credentials they just registered.
  Future<void> register({
    required String nid,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
  }) async {
    await _apiClient.dio.post(
      ApiConfig.register,
      data: {
        'nid': nid,
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone': phone,
        'password': password,
      },
    );
  }

  Future<User> login({
    required UserRole role,
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.dio.post(
      ApiConfig.login,
      data: {
        'role': roleToString(role),
        'email': email,
        'password': password,
      },
    );
    final data = response.data as Map<String, dynamic>;
    await _storageService.saveToken(data['access'] as String);
    return User.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<User> fetchProfile() async {
    final response = await _apiClient.dio.get(ApiConfig.citizenProfile);
    return User.fromJson(response.data as Map<String, dynamic>);
  }

  Future<User> updateProfile(Map<String, dynamic> data) async {
    final response = await _apiClient.dio.patch(
      ApiConfig.citizenProfile,
      data: data,
    );
    return User.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    await _apiClient.dio.patch(
      ApiConfig.changePassword,
      data: {'old_password': oldPassword, 'new_password': newPassword},
    );
  }

  Future<void> logout() async {
    try {
      await _apiClient.dio.post(ApiConfig.logout);
    } catch (_) {
      // best-effort — clear local session regardless
    }
    await _storageService.clearTokens();
  }

  Future<bool> hasValidSession() async {
    final token = await _storageService.getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
