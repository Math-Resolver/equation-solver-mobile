import 'package:equation_solver_mobile/core/localization/app_locale_controller.dart';
import 'package:equation_solver_mobile/features/menu/repository/language_preferences_repository_interface.dart';
import 'package:flutter/material.dart';

class AppLocalizationScope extends InheritedNotifier<AppLocaleController> {
  const AppLocalizationScope({
    required AppLocaleController controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  static AppLocaleController of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<AppLocalizationScope>();
    return scope?.notifier ?? _fallbackController;
  }

  static final _fallbackController = AppLocaleController(
    repository: _InMemoryLanguagePreferencesRepository(),
  );
}

class _InMemoryLanguagePreferencesRepository
    implements ILanguagePreferencesRepository {
  String _languageCode = 'pt';

  @override
  Future<String> loadLanguageCode() async => _languageCode;

  @override
  Future<void> saveLanguageCode(String languageCode) async {
    _languageCode = languageCode;
  }
}
