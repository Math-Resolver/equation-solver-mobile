import 'dart:async';

import 'package:equation_solver_mobile/core/auth/passkey_client_interface.dart';
import 'package:equation_solver_mobile/core/auth/token_storage_interface.dart';
import 'package:equation_solver_mobile/core/device/device_model_provider.dart';
import 'package:equation_solver_mobile/core/auth/token_pair.dart';
import 'package:equation_solver_mobile/features/auth/presentation/profile/profile_page_controller.dart';
import 'package:equation_solver_mobile/features/auth/repository/auth_repository_interface.dart';
import 'package:equation_solver_mobile/features/auth/repository/models/auth_challenge.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepositoryInterface {}

class MockPasskeyClient extends Mock implements IPasskeyClientInterface {}

class MockTokenStorage extends Mock implements ITokenStorageInterface {}

class MockDeviceModelProvider extends Mock implements IDeviceModelProvider {}

void main() {
  late MockAuthRepository authRepository;
  late MockPasskeyClient passkeyClient;
  late MockTokenStorage tokenStorage;
  late MockDeviceModelProvider deviceModelProvider;
  late ProfilePageController controller;

  const challenge = AuthChallenge(
    challenge: 'challenge-123',
    relyingParty: {'id': 'killmath.app'},
    user: {'id': 'user-1', 'name': 'mathe'},
  );

  setUp(() {
    authRepository = MockAuthRepository();
    passkeyClient = MockPasskeyClient();
    tokenStorage = MockTokenStorage();
    deviceModelProvider = MockDeviceModelProvider();

    when(() => tokenStorage.readAccessToken()).thenAnswer((_) async => null);
    when(
      () => deviceModelProvider.readDisplayModel(),
    ).thenAnswer((_) async => 'SM-G780G');
    when(() => tokenStorage.clear()).thenAnswer((_) async {});

    controller = ProfilePageController(
      authRepository: authRepository,
      passkeyClient: passkeyClient,
      tokenStorage: tokenStorage,
      deviceModelProvider: deviceModelProvider,
    );
  });

  group('ProfilePageController login', () {
    test(
      'loginWithPasskey returns success and performs start/auth/finish',
      () async {
        when(
          () => authRepository.startLogin(),
        ).thenAnswer((_) async => challenge);
        when(
          () => passkeyClient.authenticateCredential(
            challenge: 'challenge-123',
            relyingParty: const {'id': 'killmath.app'},
            user: const {'id': 'user-1', 'name': 'mathe'},
          ),
        ).thenAnswer((_) async => 'credential-json');
        when(
          () => authRepository.finishLogin(credential: 'credential-json'),
        ).thenAnswer(
          (_) async => const TokenPair(
            accessToken: 'access-1',
            refreshToken: 'refresh-1',
          ),
        );

        final result = await controller.loginWithPasskey();

        expect(result, ProfileSubmitStatus.success);
        expect(controller.isSubmitting, isFalse);
        verify(() => authRepository.startLogin()).called(1);
        verify(
          () => passkeyClient.authenticateCredential(
            challenge: 'challenge-123',
            relyingParty: const {'id': 'killmath.app'},
            user: const {'id': 'user-1', 'name': 'mathe'},
          ),
        ).called(1);
        verify(
          () => authRepository.finishLogin(credential: 'credential-json'),
        ).called(1);
      },
    );

    test('loginWithPasskey returns failed when finishLogin throws', () async {
      when(
        () => authRepository.startLogin(),
      ).thenAnswer((_) async => challenge);
      when(
        () => passkeyClient.authenticateCredential(
          challenge: any(named: 'challenge'),
          relyingParty: any(named: 'relyingParty'),
          user: any(named: 'user'),
        ),
      ).thenAnswer((_) async => 'credential-json');
      when(
        () => authRepository.finishLogin(credential: 'credential-json'),
      ).thenThrow(Exception('invalid credential'));

      final result = await controller.loginWithPasskey();

      expect(result, ProfileSubmitStatus.failed);
      expect(controller.isSubmitting, isFalse);
    });

    test(
      'loginWithPasskey returns passkeyUnavailable when device has no passkey support',
      () async {
        when(
          () => authRepository.startLogin(),
        ).thenAnswer((_) async => challenge);
        when(
          () => passkeyClient.authenticateCredential(
            challenge: any(named: 'challenge'),
            relyingParty: any(named: 'relyingParty'),
            user: any(named: 'user'),
          ),
        ).thenThrow(const PasskeyNotAvailableException());

        final result = await controller.loginWithPasskey();

        expect(result, ProfileSubmitStatus.passkeyUnavailable);
        verifyNever(
          () =>
              authRepository.finishLogin(credential: any(named: 'credential')),
        );
      },
    );

    test('ignores second login submit while first is running', () async {
      final completer = Completer<AuthChallenge>();
      when(
        () => authRepository.startLogin(),
      ).thenAnswer((_) => completer.future);

      final firstCall = controller.loginWithPasskey();
      final secondCall = controller.loginWithPasskey();

      final secondResult = await secondCall;
      expect(secondResult, ProfileSubmitStatus.failed);
      verify(() => authRepository.startLogin()).called(1);

      completer.complete(challenge);
      when(
        () => passkeyClient.authenticateCredential(
          challenge: any(named: 'challenge'),
          relyingParty: any(named: 'relyingParty'),
          user: any(named: 'user'),
        ),
      ).thenThrow(const PasskeyNotAvailableException());

      await firstCall;
      expect(controller.isSubmitting, isFalse);
    });
  });

  group('ProfilePageController register', () {
    test(
      'registerWithPasskey returns success and performs start/create/finish',
      () async {
        when(
          () => authRepository.startRegister(),
        ).thenAnswer((_) async => challenge);
        when(
          () => passkeyClient.createCredential(
            challenge: 'challenge-123',
            relyingParty: const {'id': 'killmath.app'},
            user: const {'id': 'user-1', 'name': 'mathe'},
          ),
        ).thenAnswer((_) async => 'credential-register-json');
        when(
          () => authRepository.finishRegister(
            credential: 'credential-register-json',
          ),
        ).thenAnswer(
          (_) async => const TokenPair(
            accessToken: 'access-2',
            refreshToken: 'refresh-2',
          ),
        );

        final result = await controller.registerWithPasskey();

        expect(result, ProfileSubmitStatus.success);
        verify(() => authRepository.startRegister()).called(1);
        verify(
          () => passkeyClient.createCredential(
            challenge: 'challenge-123',
            relyingParty: const {'id': 'killmath.app'},
            user: const {'id': 'user-1', 'name': 'mathe'},
          ),
        ).called(1);
        verify(
          () => authRepository.finishRegister(
            credential: 'credential-register-json',
          ),
        ).called(1);
      },
    );

    test(
      'registerWithPasskey returns failed when finishRegister throws',
      () async {
        when(
          () => authRepository.startRegister(),
        ).thenAnswer((_) async => challenge);
        when(
          () => passkeyClient.createCredential(
            challenge: any(named: 'challenge'),
            relyingParty: any(named: 'relyingParty'),
            user: any(named: 'user'),
          ),
        ).thenAnswer((_) async => 'credential-register-json');
        when(
          () => authRepository.finishRegister(
            credential: 'credential-register-json',
          ),
        ).thenThrow(Exception('invalid credential'));

        final result = await controller.registerWithPasskey();

        expect(result, ProfileSubmitStatus.failed);
        expect(controller.isSubmitting, isFalse);
      },
    );
  });

  group('ProfilePageController auth state', () {
    test('loadAuthState sets logged out state when token is missing', () async {
      when(() => tokenStorage.readAccessToken()).thenAnswer((_) async => null);

      await controller.loadAuthState();

      expect(controller.isLoggedIn, isFalse);
      expect(controller.deviceModel, 'Unknown device');
    });

    test('loadAuthState sets logged in state and reads device model', () async {
      when(
        () => tokenStorage.readAccessToken(),
      ).thenAnswer((_) async => 'access-token');
      when(
        () => deviceModelProvider.readDisplayModel(),
      ).thenAnswer((_) async => 'SM-G780G');

      await controller.loadAuthState();

      expect(controller.isLoggedIn, isTrue);
      expect(controller.deviceModel, 'SM-G780G');
    });

    test('logout clears token storage and resets state', () async {
      when(
        () => tokenStorage.readAccessToken(),
      ).thenAnswer((_) async => 'access-token');
      await controller.loadAuthState();

      await controller.logout();

      verify(() => tokenStorage.clear()).called(1);
      expect(controller.isLoggedIn, isFalse);
      expect(controller.deviceModel, 'Unknown device');
    });
  });
}
