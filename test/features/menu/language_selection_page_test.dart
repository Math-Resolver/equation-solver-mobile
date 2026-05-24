import 'package:equation_solver_mobile/core/localization/app_locale_controller.dart';
import 'package:equation_solver_mobile/core/localization/app_localization_scope.dart';
import 'package:equation_solver_mobile/features/menu/presentation/languages/language_selection_page.dart';
import 'package:equation_solver_mobile/features/menu/repository/language_preferences_repository_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeLanguagePreferencesRepository
    implements ILanguagePreferencesRepository {
  _FakeLanguagePreferencesRepository(this._code);

  String _code;

  @override
  Future<String> loadLanguageCode() async => _code;

  @override
  Future<void> saveLanguageCode(String languageCode) async {
    _code = languageCode;
  }
}

void main() {
  group('LanguageSelectionPage', () {
    testWidgets('renders language options from figma list', (tester) async {
      final repository = _FakeLanguagePreferencesRepository('pt');
      final controller = AppLocaleController(repository: repository);

      await tester.pumpWidget(
        AppLocalizationScope(
          controller: controller,
          child: const MaterialApp(home: LanguageSelectionPage()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Português'), findsWidgets);
      expect(find.text('Deutsch'), findsOneWidget);
      await tester.drag(find.byType(ListView), const Offset(0, -1200));
      await tester.pumpAndSettle();
      expect(find.text('Français'), findsOneWidget);
    });

    testWidgets('done saves selected language and closes page', (tester) async {
      final repository = _FakeLanguagePreferencesRepository('pt');
      final controller = AppLocaleController(repository: repository);

      await tester.pumpWidget(
        AppLocalizationScope(
          controller: controller,
          child: MaterialApp(
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LanguageSelectionPage(),
                    ),
                  );
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Deutsch'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Concluído'));
      await tester.pumpAndSettle();

      expect(controller.languageCode, 'de');
      expect(await repository.loadLanguageCode(), 'de');
      expect(find.byType(LanguageSelectionPage), findsNothing);
    });
  });
}
