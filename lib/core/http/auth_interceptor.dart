import 'package:dio/dio.dart';

import '../auth/token_storage_interface.dart';

typedef UnauthorizedHandler = Future<void> Function();

class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required ITokenStorageInterface tokenStorage,
    UnauthorizedHandler? onUnauthorized,
  }) : _tokenStorage = tokenStorage,
       _onUnauthorized = onUnauthorized;

  final ITokenStorageInterface _tokenStorage;
  final UnauthorizedHandler? _onUnauthorized;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final hasAuthorizationHeader = options.headers.containsKey('Authorization');
    if (!hasAuthorizationHeader) {
      final token = await _tokenStorage.readAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final isUnauthorized = err.response?.statusCode == 401;
    if (isUnauthorized) {
      await _tokenStorage.clear();
      if (_onUnauthorized != null) {
        await _onUnauthorized!();
      }
    }
    handler.next(err);
  }
}
