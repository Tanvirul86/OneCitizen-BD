import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:onecitizen/config/api_config.dart';
import 'package:onecitizen/models/user.dart';
import 'package:onecitizen/services/api_client.dart';
import 'package:onecitizen/services/storage_service.dart';

class AuthService {
  AuthService({
    required ApiClient apiClient,
    required StorageService storageService,
    fb.FirebaseAuth? firebaseAuth,
  })  : _apiClient = apiClient,
        _storageService = storageService,
        _firebaseAuth = firebaseAuth ?? fb.FirebaseAuth.instance;

  final ApiClient _apiClient;
  final StorageService _storageService;
  final fb.FirebaseAuth _firebaseAuth;

  String? _verificationId;

  Future<void> sendOtp(String phoneNumber) async {
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber.startsWith('+') ? phoneNumber : '+88$phoneNumber',
      verificationCompleted: (_) {},
      verificationFailed: (e) {
        throw Exception(e.message ?? 'Phone verification failed');
      },
      codeSent: (verificationId, _) {
        _verificationId = verificationId;
      },
      codeAutoRetrievalTimeout: (_) {},
      timeout: const Duration(seconds: 60),
    );
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (_verificationId == null) {
      throw Exception('Failed to send OTP. Please try again.');
    }
  }

  Future<User> verifyOtpAndLogin(String otp) async {
    if (_verificationId == null) {
      throw Exception('No verification in progress. Request OTP first.');
    }

    final credential = fb.PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: otp,
    );

    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    final firebaseToken = await userCredential.user?.getIdToken();
    if (firebaseToken == null) {
      throw Exception('Failed to obtain Firebase token');
    }

    return exchangeFirebaseToken(firebaseToken);
  }

  Future<User> exchangeFirebaseToken(String firebaseToken) async {
    final response = await _apiClient.dio.post(
      ApiConfig.firebaseTokenExchange,
      data: {'firebase_token': firebaseToken},
    );

    final data = response.data as Map<String, dynamic>;
    await _storageService.saveTokens(
      accessToken: data['access'] as String,
      refreshToken: data['refresh'] as String?,
    );

    return User.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<User> fetchProfile() async {
    final response = await _apiClient.dio.get(ApiConfig.me);
    return User.fromJson(response.data as Map<String, dynamic>);
  }

  Future<User> updateProfile(Map<String, dynamic> data) async {
    final response = await _apiClient.dio.patch(ApiConfig.profile, data: data);
    return User.fromJson(response.data as Map<String, dynamic>);
  }

  Future<User> uploadProfilePicture(String filePath) async {
    final formData = FormData.fromMap({
      'profile_picture': await MultipartFile.fromFile(filePath),
    });
    final response = await _apiClient.dio.patch(
      ApiConfig.profile,
      data: formData,
    );
    return User.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
    await _storageService.clearTokens();
  }

  Future<bool> hasValidSession() async {
    final token = await _storageService.getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
