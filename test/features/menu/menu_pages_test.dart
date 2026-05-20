import 'package:equation_solver_mobile/core/localization/app_locale_controller.dart';
import 'package:equation_solver_mobile/core/localization/app_localization_scope.dart';
import 'package:equation_solver_mobile/features/menu/presentation/about_us/about_us_page.dart';
import 'package:equation_solver_mobile/features/menu/presentation/help_center/help_center_page.dart';
import 'package:equation_solver_mobile/features/menu/repository/language_preferences_repository_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeLanguagePreferencesRepository
    implements ILanguagePreferencesRepository {
  @override
  Future<String> loadLanguageCode() async => 'pt';

  @override
  Future<void> saveLanguageCode(String languageCode) async {}
}

Widget _wrap(Widget child) {
  return AppLocalizationScope(
    controller: AppLocaleController(
      repository: _FakeLanguagePreferencesRepository(),
    ),
    child: MaterialApp(home: child),
  );
}

void main() {
  group('Menu pages', () {
    testWidgets('about page renders close action and contact section', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const AboutUsPage()));

      expect(find.text('Sobre nós'), findsOneWidget);
      expect(find.text('Fechar'), findsOneWidget);
      expect(find.text('Contacte-nos:'), findsOneWidget);
    });

    testWidgets('help page renders placeholder text', (tester) async {
      await tester.pumpWidget(_wrap(const HelpCenterPage()));

      expect(find.text('Centro de ajuda'), findsOneWidget);
      expect(
        find.text('Esta seção estará disponível em breve.'),
        findsOneWidget,
      );
    });
  });
}
