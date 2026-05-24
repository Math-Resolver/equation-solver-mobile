import 'package:equation_solver_mobile/core/localization/app_locale_controller.dart';
import 'package:equation_solver_mobile/core/localization/app_localization_scope.dart';
import 'package:equation_solver_mobile/features/menu/presentation/about_us/about_us_page.dart';
import 'package:equation_solver_mobile/features/menu/presentation/help_center/help_center_page.dart';
import 'package:equation_solver_mobile/features/menu/presentation/languages/language_selection_page.dart';
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
      expect(find.text('Fechar'), findsOneWidget);
      expect(find.text('Como podemos te ajudar?'), findsOneWidget);
      expect(find.text('Como funciona?'), findsOneWidget);
      expect(find.text('Como funciona o chatbot?'), findsOneWidget);
      expect(find.text('Não tá resolvendo o cálculo!'), findsOneWidget);
      expect(find.text('Português'), findsOneWidget);
    });

    testWidgets('help faq accordion keeps a single expanded section', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const HelpCenterPage()));

      expect(find.text('Lorem ipsum dolor sit amet.'), findsNothing);

      await tester.tap(find.text('Como funciona?'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Lorem ipsum dolor sit amet.'),
        findsOneWidget,
      );

      await tester.tap(find.text('Como funciona o chatbot?'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Lorem ipsum dolor sit amet.'),
        findsOneWidget,
      );
    });

    testWidgets('help page close action pops route', (tester) async {
      await tester.pumpWidget(
        AppLocalizationScope(
          controller: AppLocaleController(
            repository: _FakeLanguagePreferencesRepository(),
          ),
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                return Scaffold(
                  body: Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const HelpCenterPage(),
                          ),
                        );
                      },
                      child: const Text('open'),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.byType(HelpCenterPage), findsOneWidget);

      await tester.tap(find.text('Fechar'));
      await tester.pumpAndSettle();

      expect(find.byType(HelpCenterPage), findsNothing);
    });

    testWidgets('help page language selector opens language page', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const HelpCenterPage()));

      await tester.tap(find.text('Português'));
      await tester.pumpAndSettle();

      expect(find.byType(LanguageSelectionPage), findsOneWidget);
    });
  });
}
