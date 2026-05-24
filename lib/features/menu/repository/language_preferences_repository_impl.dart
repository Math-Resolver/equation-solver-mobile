import 'package:equation_solver_mobile/core/localization/app_strings_catalog.dart';
import 'package:equation_solver_mobile/features/menu/repository/language_preferences_repository_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguagePreferencesRepositoryImpl implements ILanguagePreferencesRepository {
  static const _languageCodeKey = 'app_language_code';

  @override
  Future<String> loadLanguageCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageCodeKey) ?? AppStringsCatalog.fallbackLanguageCode;
  }

  @override
  Future<void> saveLanguageCode(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageCodeKey, languageCode);
  }
}
