import 'package:equation_solver_mobile/core/auth/passkey_client_interface.dart';
import 'package:flutter/services.dart';

class PasskeyClientImpl implements IPasskeyClientInterface {
  PasskeyClientImpl({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel(_channelName);

  static const _channelName = 'equation_solver_mobile/passkey';
  final MethodChannel _channel;

  @override
  Future<String> authenticateCredential({
    required String challenge,
    required Map<String, dynamic> relyingParty,
    required Map<String, dynamic> user,
  }) {
    return _invokeCredential(
      method: 'authenticateCredential',
      challenge: challenge,
      relyingParty: relyingParty,
      user: user,
    );
  }

  @override
  Future<String> createCredential({
    required String challenge,
    required Map<String, dynamic> relyingParty,
    required Map<String, dynamic> user,
  }) {
    return _invokeCredential(
      method: 'createCredential',
      challenge: challenge,
      relyingParty: relyingParty,
      user: user,
    );
  }

  Future<String> _invokeCredential({
    required String method,
    required String challenge,
    required Map<String, dynamic> relyingParty,
    required Map<String, dynamic> user,
  }) async {
    try {
      final credential = await _channel.invokeMethod<String>(method, {
        'challenge': challenge,
        'relyingParty': relyingParty,
        'user': user,
      });
      if (credential == null || credential.trim().isEmpty) {
        throw const PasskeyCredentialException();
      }
      return credential;
    } on MissingPluginException {
      throw const PasskeyNotAvailableException();
    } on PlatformException catch (error) {
      if (error.code == 'not_available') {
        throw const PasskeyNotAvailableException();
      }
      throw PasskeyCredentialException(error.message ?? error.code);
    }
  }
}
