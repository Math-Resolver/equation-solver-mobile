import 'package:equation_solver_mobile/core/auth/passkey_client_interface.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class MockPasskeyClientImpl implements IPasskeyClientInterface {
  MockPasskeyClientImpl({LocalAuthentication? localAuthentication})
    : _localAuthentication = localAuthentication ?? LocalAuthentication();

  final LocalAuthentication _localAuthentication;

  @override
  Future<String> authenticateCredential({
    required String challenge,
    required Map<String, dynamic> relyingParty,
    required Map<String, dynamic> user,
  }) async {
    await _requireBiometricConfirmation();
    return _buildCredential(challenge, relyingParty, user);
  }

  @override
  Future<String> createCredential({
    required String challenge,
    required Map<String, dynamic> relyingParty,
    required Map<String, dynamic> user,
  }) async {
    await _requireBiometricConfirmation();
    return _buildCredential(challenge, relyingParty, user);
  }

  Future<void> _requireBiometricConfirmation() async {
    final canAuthenticateWithBiometrics =
        await _localAuthentication.canCheckBiometrics;
    final canAuthenticateWithDeviceSupport = await _localAuthentication
        .isDeviceSupported();
    if (!canAuthenticateWithBiometrics && !canAuthenticateWithDeviceSupport) {
      throw const PasskeyNotAvailableException();
    }

    try {
      final authenticated = await _localAuthentication.authenticate(
        localizedReason: 'Confirme sua digital para continuar no Killmath',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: false,
        ),
      );
      if (!authenticated) {
        throw const PasskeyCredentialException('Digital nao confirmada');
      }
    } on MissingPluginException {
      throw const PasskeyNotAvailableException();
    } on PlatformException catch (error) {
      if (_isUnavailableCode(error.code)) {
        throw const PasskeyNotAvailableException();
      }
      throw PasskeyCredentialException(error.message ?? error.code);
    }
  }

  bool _isUnavailableCode(String code) {
    return code == 'NotAvailable' ||
        code == 'notAvailable' ||
        code == 'PasscodeNotSet' ||
        code == 'NotEnrolled' ||
        code == 'no_biometric_hardware' ||
        code == 'no_biometrics_enrolled';
  }

  String _buildCredential(
    String challenge,
    Map<String, dynamic> relyingParty,
    Map<String, dynamic> user,
  ) {
    final userId = user['id']?.toString() ?? 'unknown-user';
    final relyingPartyId = relyingParty['id']?.toString() ?? 'unknown-rp';
    return 'mock-passkey:$relyingPartyId:$userId:$challenge';
  }
}
