import 'package:flutter/foundation.dart';
import 'package:onecitizen/models/user.dart';
import 'package:onecitizen/services/auth_service.dart';
import 'package:onecitizen/services/storage_service.dart';

const _devUsers = {
  UserRole.citizen: User(
    id: 'dev-citizen',
    phoneNumber: '+8801700000001',
    fullName: 'Dev Citizen',
    nid: '1234567890',
    role: UserRole.citizen,
  ),
  UserRole.officer: User(
    id: 'dev-officer',
    phoneNumber: '+8801700000002',
    fullName: 'Dev Officer',
    nid: '1234567891',
    role: UserRole.officer,
  ),
  UserRole.admin: User(
    id: 'dev-admin',
    phoneNumber: '+8801700000003',
    fullName: 'Dev Admin',
    nid: '1234567892',
    role: UserRole.admin,
  ),
};

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  AuthProvider({
    required AuthService authService,
    required StorageService storageService,
  })  : _authService = authService,
        _storageService = storageService;

  final AuthService _authService;
  final StorageService _storageService;

  AuthStatus status = AuthStatus.initial;
  User? user;
  String? errorMessage;
  String? phoneNumber;

  Future<void> checkSession() async {
    status = AuthStatus.loading;
    notifyListeners();

    try {
      final hasSession = await _authService.hasValidSession();
      if (hasSession) {
        user = await _authService.fetchProfile();
        status = AuthStatus.authenticated;
      } else {
        status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<void> sendOtp(String phone) async {
    status = AuthStatus.loading;
    errorMessage = null;
    phoneNumber = phone;
    notifyListeners();

    try {
      await _authService.sendOtp(phone);
      status = AuthStatus.unauthenticated;
    } catch (e) {
      errorMessage = e.toString();
      status = AuthStatus.error;
    }
    notifyListeners();
  }

  Future<bool> verifyOtp(String otp) async {
    status = AuthStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      user = await _authService.verifyOtpAndLogin(otp);
      status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    try {
      user = await _authService.updateProfile(data);
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> uploadProfilePicture(String path) async {
    try {
      user = await _authService.uploadProfilePicture(path);
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    user = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void devLogin(UserRole role) {
    assert(kDebugMode, 'devLogin only available in debug mode');
    user = _devUsers[role]!;
    status = AuthStatus.authenticated;
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    await _storageService.setOnboardingComplete(true);
  }

  Future<bool> needsProfileSetup() async {
    if (user == null) return false;
    return user!.fullName == null || user!.nid == null;
  }
}
