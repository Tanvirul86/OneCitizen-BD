import 'package:flutter/foundation.dart';
import 'package:onecitizen/models/user.dart';
import 'package:onecitizen/services/auth_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  AuthProvider({required AuthService authService}) : _authService = authService;

  final AuthService _authService;

  AuthStatus status = AuthStatus.initial;
  User? user;
  String? errorMessage;

  Future<void> checkSession() async {
    status = AuthStatus.loading;
    notifyListeners();

    try {
      final hasSession = await _authService.hasValidSession();
      if (hasSession) {
        final restoredUser = await _authService.fetchProfile();
        if (restoredUser.role == UserRole.admin) {
          // Admin sessions must not survive an app restart — require the
          // password again instead of silently restoring the last session.
          await _authService.logout();
          status = AuthStatus.unauthenticated;
        } else {
          user = restoredUser;
          status = AuthStatus.authenticated;
        }
      } else {
        status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
  }) async {
    status = AuthStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      await _authService.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        password: password,
      );
      // Account created but not signed in — the user must log in manually.
      status = AuthStatus.unauthenticated;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login({
    required UserRole role,
    required String email,
    required String password,
  }) async {
    status = AuthStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      user = await _authService.login(
        role: role,
        email: email,
        password: password,
      );
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
    errorMessage = null;
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

  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    errorMessage = null;
    try {
      await _authService.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    errorMessage = null;
    try {
      await _authService.sendPasswordResetEmail(email);
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

  bool needsProfileCompletion() {
    if (user == null) return false;
    return !user!.profileComplete;
  }
}
