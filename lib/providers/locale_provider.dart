import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage { en, bn }

/// Holds the user's chosen app language (Bangla/English) and persists it
/// locally so the choice survives app restarts. This is a lightweight,
/// dictionary-based translation layer (see lib/l10n/app_strings.dart) rather
/// than Flutter's ARB/codegen localization — kept simple so screens can be
/// migrated to it incrementally.
class LocaleProvider extends ChangeNotifier {
  static const _prefsKey = 'app_language';

  AppLanguage _language = AppLanguage.en;
  AppLanguage get language => _language;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsKey);
    if (saved == 'bn') {
      _language = AppLanguage.bn;
      notifyListeners();
    }
  }

  Future<void> toggle() => setLanguage(_language == AppLanguage.en ? AppLanguage.bn : AppLanguage.en);

  Future<void> setLanguage(AppLanguage language) async {
    if (_language == language) return;
    _language = language;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, language == AppLanguage.bn ? 'bn' : 'en');
  }
}
