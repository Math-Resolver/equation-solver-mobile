import 'package:equation_solver_mobile/core/localization/app_locale_controller.dart';
import 'package:equation_solver_mobile/core/localization/app_localization_scope.dart';
import 'package:equation_solver_mobile/features/auth/presentation/profile/profile_page.dart';
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
  group('ProfilePage', () {
    testWidgets('renders page title "Meu Perfil"', (tester) async {
      await tester.pumpWidget(_wrap(const ProfilePage()));

      expect(find.text('Meu Perfil'), findsWidgets);
    });

    testWidgets('renders Login and Cadastrar tabs', (tester) async {
      await tester.pumpWidget(_wrap(const ProfilePage()));

      expect(find.text('Entrar'), findsWidgets);
      expect(find.text('Cadastrar'), findsOneWidget);
    });

    testWidgets('login tab shows email field and submit button', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const ProfilePage()));

      // Login tab is shown by default
      expect(find.widgetWithText(TextFormField, 'E-mail'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Entrar'), findsOneWidget);
    });

    testWidgets('register tab shows name and email fields', (tester) async {
      await tester.pumpWidget(_wrap(const ProfilePage()));

      await tester.tap(find.text('Cadastrar'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(TextFormField, 'Nome'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'E-mail'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Criar conta'), findsOneWidget);
    });

    testWidgets('login shows error snackbar when email is empty', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const ProfilePage()));

      await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('register shows error snackbar when fields are empty', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const ProfilePage()));

      await tester.tap(find.text('Cadastrar'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Criar conta'));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
    });
  });
}
