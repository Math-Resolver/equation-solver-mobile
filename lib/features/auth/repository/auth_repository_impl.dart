import 'package:equation_solver_mobile/core/auth/token_pair.dart';
import 'package:equation_solver_mobile/core/auth/token_storage_interface.dart';
import 'package:equation_solver_mobile/core/http/http_client_interface.dart';

import 'auth_repository_interface.dart';
import 'models/auth_challenge.dart';

class AuthRepositoryImpl implements IAuthRepositoryInterface {
  AuthRepositoryImpl({
    required IHttpClientInterface httpClient,
    required ITokenStorageInterface tokenStorage,
  })  : _httpClient = httpClient,
        _tokenStorage = tokenStorage;

  final IHttpClientInterface _httpClient;
  final ITokenStorageInterface _tokenStorage;

  @override
  Future<TokenPair> finishLogin({required String credential}) async {
    final data = await _httpClient.post(
      '/v1/auth/login/finish',
      data: {'credential': credential},
    );
    final tokens = TokenPair.fromJson(data);
    await _tokenStorage.writeTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );
    return tokens;
  }

  @override
  Future<TokenPair> finishRegister({required String credential}) async {
    final data = await _httpClient.post(
      '/v1/auth/register/finish',
      data: {'credential': credential},
    );
    final tokens = TokenPair.fromJson(data);
    await _tokenStorage.writeTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );
    return tokens;
  }

  @override
  Future<AuthChallenge> startLogin({required String email}) async {
    final data = await _httpClient.post(
      '/v1/auth/login',
      data: {'email': email}, //TODO Voltar e reecer
    );
    return AuthChallenge.fromJson(data);
  }

  @override
  Future<AuthChallenge> startRegister({
    required String displayName,
    required String deviceFingerprint,
  }) async {
    final data = await _httpClient.post(
      '/v1/auth/register',
      data: {
        'displayName': displayName,
        'deviceFingerprint': deviceFingerprint,
      },
    );
    return AuthChallenge.fromJson(data);
  }
}
