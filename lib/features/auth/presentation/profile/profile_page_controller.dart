import 'package:equation_solver_mobile/core/auth/passkey_client_interface.dart';
import 'package:equation_solver_mobile/features/auth/repository/auth_repository_interface.dart';
import 'package:flutter/foundation.dart';

enum ProfileSubmitStatus { success, passkeyUnavailable, failed }

class ProfilePageController extends ChangeNotifier {
  ProfilePageController({
    required IAuthRepositoryInterface authRepository,
    required IPasskeyClientInterface passkeyClient,
  }) : _authRepository = authRepository,
       _passkeyClient = passkeyClient;

  final IAuthRepositoryInterface _authRepository;
  final IPasskeyClientInterface _passkeyClient;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  Future<ProfileSubmitStatus> loginWithPasskey() async {
    if (_isSubmitting) {
      return ProfileSubmitStatus.failed;
    }

    _setSubmitting(true);
    try {
      final challenge = await _authRepository.startLogin();
      final credential = await _passkeyClient.authenticateCredential(
        challenge: challenge.challenge,
        relyingParty: challenge.relyingParty,
        user: challenge.user,
      );
      await _authRepository.finishLogin(credential: credential);
      return ProfileSubmitStatus.success;
    } on PasskeyNotAvailableException {
      return ProfileSubmitStatus.passkeyUnavailable;
    } catch (_) {
      return ProfileSubmitStatus.failed;
    } finally {
      _setSubmitting(false);
    }
  }

  Future<ProfileSubmitStatus> registerWithPasskey() async {
    if (_isSubmitting) {
      return ProfileSubmitStatus.failed;
    }

    _setSubmitting(true);
    try {
      final challenge = await _authRepository.startRegister();
      final credential = await _passkeyClient.createCredential(
        challenge: challenge.challenge,
        relyingParty: challenge.relyingParty,
        user: challenge.user,
      );
      await _authRepository.finishRegister(credential: credential);
      return ProfileSubmitStatus.success;
    } on PasskeyNotAvailableException {
      return ProfileSubmitStatus.passkeyUnavailable;
    } catch (_) {
      return ProfileSubmitStatus.failed;
    } finally {
      _setSubmitting(false);
    }
  }

  void _setSubmitting(bool value) {
    if (_isSubmitting == value) {
      return;
    }
    _isSubmitting = value;
    notifyListeners();
  }
}
