import 'package:dio/dio.dart';
import 'package:equation_solver_mobile/core/auth/token_storage_interface.dart';
import 'package:equation_solver_mobile/core/http/auth_interceptor.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_http_client_adapter.dart';

class InMemoryTokenStorage implements ITokenStorageInterface {
  InMemoryTokenStorage({this.accessToken, this.refreshToken});

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
  group('AuthInterceptor', () {
    test('adds bearer token when access token exists', () async {
      late RequestOptions capturedRequest;
      final storage = InMemoryTokenStorage(accessToken: 'access-123');

      final dio = Dio(BaseOptions(baseUrl: 'http://10.0.2.2:8000'));
      dio.interceptors.add(AuthInterceptor(tokenStorage: storage));
      dio.httpClientAdapter = FakeHttpClientAdapter(
        handler: (options) async {
          capturedRequest = options;
          return const FakeAdapterResponse(statusCode: 200, data: {'ok': true});
        },
      );

      await dio.post('/v1/conversation', data: {'topic': 'Logarithm'});

      expect(capturedRequest.headers['Authorization'], 'Bearer access-123');
    });

    test('clears token storage on unauthorized response', () async {
      final storage = InMemoryTokenStorage(
        accessToken: 'access-123',
        refreshToken: 'refresh-123',
      );

      final dio = Dio(BaseOptions(baseUrl: 'http://10.0.2.2:8000'));
      dio.interceptors.add(AuthInterceptor(tokenStorage: storage));
      dio.httpClientAdapter = FakeHttpClientAdapter(
        handler: (_) async => const FakeAdapterResponse(
          statusCode: 401,
          data: {'detail': 'unauthorized'},
        ),
      );

      try {
        await dio.get('/v1/protected');
      } on DioException {
        // expected in test
      }

      expect(await storage.readAccessToken(), isNull);
      expect(await storage.readRefreshToken(), isNull);
    });
  });
}
