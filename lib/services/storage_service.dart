import 'package:shared_preferences/shared_preferences.dart';

/// Local-only preferences that aren't part of the Firebase-backed data model.
/// Firebase Auth persists the session itself, so this no longer holds tokens.
class StorageService {
  static const _onboardingCompleteKey = 'onboarding_complete';

  Future<void> setOnboardingComplete(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompleteKey, value);
  }

  Future<bool> isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingCompleteKey) ?? false;
  }
}
