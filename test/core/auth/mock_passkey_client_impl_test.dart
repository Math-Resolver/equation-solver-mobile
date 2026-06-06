import 'package:equation_solver_mobile/core/auth/mock_passkey_client_impl.dart';
import 'package:equation_solver_mobile/core/auth/passkey_client_interface.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockLocalAuthentication extends Mock implements LocalAuthentication {}

void main() {
  setUpAll(() {
    registerFallbackValue(const AuthenticationOptions());
  });

  group('MockPasskeyClientImpl', () {
    late MockLocalAuthentication localAuthentication;

    setUp(() {
      localAuthentication = MockLocalAuthentication();
    });

    test(
      'requires biometric confirmation before returning a login credential',
      () async {
        when(
          () => localAuthentication.canCheckBiometrics,
        ).thenAnswer((_) async => true);
        when(
          () => localAuthentication.isDeviceSupported(),
        ).thenAnswer((_) async => true);
        when(
          () => localAuthentication.authenticate(
            localizedReason: any(named: 'localizedReason'),
            options: any(named: 'options'),
          ),
        ).thenAnswer((_) async => true);

        final client = MockPasskeyClientImpl(
          localAuthentication: localAuthentication,
        );

        final loginCredential = await client.authenticateCredential(
          challenge: 'challenge-1',
          relyingParty: const {'id': 'killmath'},
          user: const {'id': 'user-1'},
        );

        expect(loginCredential, startsWith('mock-passkey:killmath:user-1:'));
        verify(
          () => localAuthentication.authenticate(
            localizedReason: any(named: 'localizedReason'),
            options: any(named: 'options'),
          ),
        ).called(1);
      },
    );

    test(
      'requires biometric confirmation before returning a register credential',
      () async {
        when(
          () => localAuthentication.canCheckBiometrics,
        ).thenAnswer((_) async => true);
        when(
          () => localAuthentication.isDeviceSupported(),
        ).thenAnswer((_) async => true);
        when(
          () => localAuthentication.authenticate(
            localizedReason: any(named: 'localizedReason'),
            options: any(named: 'options'),
          ),
        ).thenAnswer((_) async => true);

        final client = MockPasskeyClientImpl(
          localAuthentication: localAuthentication,
        );

        final registerCredential = await client.createCredential(
          challenge: 'challenge-2',
          relyingParty: const {'id': 'killmath'},
          user: const {'id': 'user-1'},
        );

        expect(registerCredential, startsWith('mock-passkey:killmath:user-1:'));
        verify(
          () => localAuthentication.authenticate(
            localizedReason: any(named: 'localizedReason'),
            options: any(named: 'options'),
          ),
        ).called(1);
      },
    );

    test('returns unavailable when biometrics are not supported', () async {
      when(
        () => localAuthentication.canCheckBiometrics,
      ).thenAnswer((_) async => false);
      when(
        () => localAuthentication.isDeviceSupported(),
      ).thenAnswer((_) async => false);

      final client = MockPasskeyClientImpl(
        localAuthentication: localAuthentication,
      );

      expect(
        () => client.createCredential(
          challenge: 'challenge-2',
          relyingParty: const {'id': 'killmath'},
          user: const {'id': 'user-1'},
        ),
        throwsA(isA<PasskeyNotAvailableException>()),
      );
    });
  });
}
