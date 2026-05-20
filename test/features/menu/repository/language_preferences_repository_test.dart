import 'package:equation_solver_mobile/features/menu/repository/language_preferences_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('LanguagePreferencesRepositoryImpl', () {
    test('returns portuguese when nothing was saved', () async {
      SharedPreferences.setMockInitialValues({});
      final repository = LanguagePreferencesRepositoryImpl();

      final languageCode = await repository.loadLanguageCode();

      expect(languageCode, 'pt');
    });

    test('saves and loads selected language code', () async {
      SharedPreferences.setMockInitialValues({});
      final repository = LanguagePreferencesRepositoryImpl();

      await repository.saveLanguageCode('en');
      final languageCode = await repository.loadLanguageCode();

      expect(languageCode, 'en');
    });
  });
}
