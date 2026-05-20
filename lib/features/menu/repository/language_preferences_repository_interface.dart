abstract class ILanguagePreferencesRepository {
  Future<void> saveLanguageCode(String languageCode);
  Future<String> loadLanguageCode();
}
