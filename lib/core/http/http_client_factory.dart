import 'package:dio/dio.dart';

import '../auth/token_storage_interface.dart';
import 'auth_interceptor.dart';
import 'dio_http_client.dart';
import 'http_client_interface.dart';

IHttpClientInterface buildApiHttpClient({
  required String baseUrl,
  required ITokenStorageInterface tokenStorage,
  UnauthorizedHandler? onUnauthorized,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      headers: const {'Content-Type': 'application/json'},
    ),
  );
  dio.interceptors.add(
    AuthInterceptor(tokenStorage: tokenStorage, onUnauthorized: onUnauthorized),
  );
  return DioHttpClient(dio);
}
