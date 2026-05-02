import 'package:equation_solver_mobile/core/auth/token_storage_interface.dart';
import 'package:equation_solver_mobile/features/auth/repository/auth_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_http_client.dart';

class InMemoryTokenStorage implements ITokenStorageInterface {
  String? accessToken;
  String? refreshToken;

  @override
  Future<void> clear() async {
    accessToken = null;
    refreshToken = null;
  }

  @override
  Future<String?> readAccessToken() async => accessToken;

  @override
  Future<String?> readRefreshToken() async => refreshToken;

  @override
  Future<void> writeTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
  }
}

void main() {
  group('AuthRepositoryImpl', () {
    test('startLogin sends email and parses challenge payload', () async {
      final httpClient = FakeHttpClient(
        handler: (request) async => {
          'challenge': 'abc123',
          'relyingParty': {'id': 'seuapp.com', 'name': 'Seu App'},
          'user': {'id': 'uuid-123', 'username': 'user@email.com'},
        },
      );

      final repository = AuthRepositoryImpl(
        httpClient: httpClient,
        tokenStorage: InMemoryTokenStorage(),
      );

      final challenge = await repository.startLogin(email: 'user@email.com');

      final request = httpClient.requests.single;
      expect(request.path, '/v1/auth/login');
      expect(request.method, 'POST');
      expect(request.data, {'email': 'user@email.com'});
      expect(challenge.challenge, 'abc123');
      expect(challenge.user['username'], 'user@email.com');
    });

    test('finishLogin saves access and refresh tokens', () async {
      final tokenStorage = InMemoryTokenStorage();
      final httpClient = FakeHttpClient(
        handler: (request) async => {
          'access_token': 'access-1',
          'refresh_token': 'refresh-1',
        },
      );

      final repository = AuthRepositoryImpl(
        httpClient: httpClient,
        tokenStorage: tokenStorage,
      );

      final tokens = await repository.finishLogin(
        credential: 'signed-credential',
      );

      final request = httpClient.requests.single;
      expect(request.path, '/v1/auth/login/finish');
      expect(request.method, 'POST');
      expect(request.data, {'credential': 'signed-credential'});
      expect(tokens.accessToken, 'access-1');
      expect(tokens.refreshToken, 'refresh-1');
      expect(await tokenStorage.readAccessToken(), 'access-1');
      expect(await tokenStorage.readRefreshToken(), 'refresh-1');
    });
  });
}
