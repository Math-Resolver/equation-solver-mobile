import 'package:equation_solver_mobile/core/localization/app_strings_catalog.dart';
import 'package:equation_solver_mobile/core/localization/app_text_key.dart';
import 'package:equation_solver_mobile/features/menu/repository/language_preferences_repository_interface.dart';
import 'package:flutter/material.dart';

class AppLocaleController extends ChangeNotifier {
  AppLocaleController({
    required ILanguagePreferencesRepository repository,
    AppStringsCatalog catalog = const AppStringsCatalog(),
  }) : _repository = repository,
       _catalog = catalog;

  final ILanguagePreferencesRepository _repository;
  final AppStringsCatalog _catalog;
  String _languageCode = AppStringsCatalog.fallbackLanguageCode;

  String get languageCode => _languageCode;

  String get currentLanguageName => _catalog.languageNameForMenu(_languageCode);

  List<SupportedLanguageOption> get supportedLanguageOptions =>
      AppStringsCatalog.supportedLanguageOptions;

  Locale get locale {
    if (_languageCode == 'zh_TW') {
      return const Locale('zh', 'TW');
    }
    return Locale(_languageCode);
  }

  String text(AppTextKey key) {
    return _catalog.text(key: key, languageCode: _languageCode);
  }

  Future<void> loadSavedLanguage() async {
    _languageCode = await _repository.loadLanguageCode();
    notifyListeners();
  }

  Future<void> setLanguageCode(String languageCode) async {
    _languageCode = languageCode;
    await _repository.saveLanguageCode(languageCode);
    notifyListeners();
  }
}
