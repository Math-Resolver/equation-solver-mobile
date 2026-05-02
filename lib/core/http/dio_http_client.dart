import 'package:dio/dio.dart';

import 'http_client_interface.dart';
import 'http_exception.dart';

class DioHttpClient implements IHttpClientInterface {
  DioHttpClient(this._dio);

  final Dio _dio;

  @override
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: queryParameters,
      );
      return response.data ?? const {};
    } on DioException catch (e) {
      throw HttpException(
        statusCode: e.response?.statusCode ?? 0,
        message: e.message ?? '',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> post(String path, {Object? data}) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        path,
        data: data,
      );
      return response.data ?? const {};
    } on DioException catch (e) {
      throw HttpException(
        statusCode: e.response?.statusCode ?? 0,
        message: e.message ?? '',
      );
    }
  }
}
