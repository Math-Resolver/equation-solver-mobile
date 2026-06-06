import 'package:equation_solver_mobile/core/auth/passkey_client_interface.dart';
import 'package:equation_solver_mobile/core/auth/token_storage_interface.dart';
import 'package:equation_solver_mobile/core/device/device_model_provider.dart';
import 'package:equation_solver_mobile/features/auth/repository/auth_repository_interface.dart';
import 'package:flutter/foundation.dart';

enum ProfileSubmitStatus { success, passkeyUnavailable, failed }

class ProfilePageController extends ChangeNotifier {
  ProfilePageController({
    required IAuthRepositoryInterface authRepository,
    required IPasskeyClientInterface passkeyClient,
    required ITokenStorageInterface tokenStorage,
    required IDeviceModelProvider deviceModelProvider,
  }) : _authRepository = authRepository,
       _passkeyClient = passkeyClient,
       _tokenStorage = tokenStorage,
       _deviceModelProvider = deviceModelProvider;

  final IAuthRepositoryInterface _authRepository;
  final IPasskeyClientInterface _passkeyClient;
  final ITokenStorageInterface _tokenStorage;
  final IDeviceModelProvider _deviceModelProvider;

  bool _isAuthStateLoading = false;
  bool get isAuthStateLoading => _isAuthStateLoading;

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  String _deviceModel = 'Unknown device';
  String get deviceModel => _deviceModel;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  Future<void> loadAuthState() async {
    if (_isAuthStateLoading) {
      return;
    }

    _setAuthStateLoading(true);
    try {
      final accessToken = await _tokenStorage.readAccessToken();
      final hasAccessToken = (accessToken ?? '').trim().isNotEmpty;
      _isLoggedIn = hasAccessToken;
      if (hasAccessToken) {
        _deviceModel = await _deviceModelProvider.readDisplayModel();
      } else {
        _deviceModel = 'Unknown device';
      }
    } finally {
      _setAuthStateLoading(false);
      notifyListeners();
    }
  }

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
      _isLoggedIn = true;
      _deviceModel = await _deviceModelProvider.readDisplayModel();
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
      _isLoggedIn = true;
      _deviceModel = await _deviceModelProvider.readDisplayModel();
      return ProfileSubmitStatus.success;
    } on PasskeyNotAvailableException {
      return ProfileSubmitStatus.passkeyUnavailable;
    } catch (_) {
      return ProfileSubmitStatus.failed;
    } finally {
      _setSubmitting(false);
    }
  }

  Future<void> logout() async {
    if (_isSubmitting) {
      return;
    }

    _setSubmitting(true);
    try {
      await _tokenStorage.clear();
      _isLoggedIn = false;
      _deviceModel = 'Unknown device';
    } finally {
      _setSubmitting(false);
      notifyListeners();
    }
  }

  void _setAuthStateLoading(bool value) {
    if (_isAuthStateLoading == value) {
      return;
    }
    _isAuthStateLoading = value;
    notifyListeners();
  }

  void _setSubmitting(bool value) {
    if (_isSubmitting == value) {
      return;
    }
    _isSubmitting = value;
    notifyListeners();
  }
}
