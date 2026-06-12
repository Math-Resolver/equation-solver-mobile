abstract class IPasskeyClientInterface {
  Future<String> createCredential({
    required String challenge,
    required Map<String, dynamic> relyingParty,
    required Map<String, dynamic> user,
  });

  Future<String> authenticateCredential({
    required String challenge,
    required Map<String, dynamic> relyingParty,
    required Map<String, dynamic> user,
  });
}

class PasskeyNotAvailableException implements Exception {
  const PasskeyNotAvailableException();
}

class PasskeyCredentialException implements Exception {
  const PasskeyCredentialException([this.message = 'Passkey operation failed']);

  final String message;
}
