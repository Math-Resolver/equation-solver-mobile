import 'package:equation_solver_mobile/core/localization/app_locale_controller.dart';
import 'package:equation_solver_mobile/core/localization/app_localization_scope.dart';
import 'package:equation_solver_mobile/core/auth/passkey_client_interface.dart';
import 'package:equation_solver_mobile/features/auth/presentation/profile/profile_page.dart';
import 'package:equation_solver_mobile/features/auth/repository/auth_repository_interface.dart';
import 'package:equation_solver_mobile/features/auth/repository/models/auth_challenge.dart';
import 'package:equation_solver_mobile/features/menu/repository/language_preferences_repository_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:equation_solver_mobile/features/auth/presentation/profile/profile_page_controller.dart';

class _FakeLanguagePreferencesRepository
    implements ILanguagePreferencesRepository {
  @override
  Future<String> loadLanguageCode() async => 'pt';

  @override
  Future<void> saveLanguageCode(String languageCode) async {}
}

class _MockAuthRepository extends Mock implements IAuthRepositoryInterface {}

class _MockPasskeyClient extends Mock implements IPasskeyClientInterface {}

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
    late _MockAuthRepository authRepository;
    late _MockPasskeyClient passkeyClient;

    setUp(() {
      authRepository = _MockAuthRepository();
      passkeyClient = _MockPasskeyClient();
    });

    testWidgets('renders white background and login mode title', (tester) async {
      await tester.pumpWidget(_wrap(const ProfilePage()));

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, Colors.white);
      expect(find.text('Entrar'), findsWidgets);
    });

    testWidgets('renders close action and app branding', (tester) async {
      await tester.pumpWidget(_wrap(const ProfilePage()));

      expect(find.byKey(const Key('profile_close_button')), findsOneWidget);
      expect(find.text('Fechar'), findsOneWidget);
      expect(find.text('killmath'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('shows login action button and toggle', (tester) async {
      await tester.pumpWidget(_wrap(const ProfilePage()));

      expect(find.byType(TextFormField), findsNothing);
      expect(find.byKey(const Key('profile_primary_action_button')), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Entrar'), findsOneWidget);
      expect(find.byKey(const Key('profile_toggle_mode_button')), findsOneWidget);
    });

    testWidgets('toggle switches from login to register mode', (tester) async {
      await tester.pumpWidget(_wrap(const ProfilePage()));

      await tester.tap(find.byKey(const Key('profile_toggle_mode_button')));
      await tester.pumpAndSettle();

      expect(find.text('Cadastrar'), findsWidgets);
      expect(
        find.widgetWithText(ElevatedButton, 'Criar conta'),
        findsOneWidget,
      );
    });

    testWidgets('login submit triggers snackbar feedback', (tester) async {
      when(() => authRepository.startLogin()).thenAnswer(
        (_) async => const AuthChallenge(
          challenge: 'abc',
          relyingParty: {'id': 'killmath.app'},
          user: {'id': 'user-1'},
        ),
      );
      when(
        () => passkeyClient.authenticateCredential(
          challenge: any(named: 'challenge'),
          relyingParty: any(named: 'relyingParty'),
          user: any(named: 'user'),
        ),
      ).thenThrow(const PasskeyNotAvailableException());

      final controller = ProfilePageController(
        authRepository: authRepository,
        passkeyClient: passkeyClient,
      );

      await tester.pumpWidget(_wrap(ProfilePage(controller: controller)));

      await tester.tap(find.byKey(const Key('profile_primary_action_button')));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('register submit triggers snackbar feedback', (tester) async {
      when(() => authRepository.startRegister()).thenAnswer(
        (_) async => const AuthChallenge(
          challenge: 'abc',
          relyingParty: {'id': 'killmath.app'},
          user: {'id': 'user-1'},
        ),
      );
      when(
        () => passkeyClient.createCredential(
          challenge: any(named: 'challenge'),
          relyingParty: any(named: 'relyingParty'),
          user: any(named: 'user'),
        ),
      ).thenThrow(const PasskeyNotAvailableException());

      final controller = ProfilePageController(
        authRepository: authRepository,
        passkeyClient: passkeyClient,
      );

      await tester.pumpWidget(_wrap(ProfilePage(controller: controller)));

      await tester.tap(find.byKey(const Key('profile_toggle_mode_button')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('profile_primary_action_button')));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
    });
  });
}
