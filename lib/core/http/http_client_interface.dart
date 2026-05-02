abstract class IHttpClientInterface {
  Future<Map<String, dynamic>> get(
    String path, { Map<String, dynamic>? queryParameters });
  Future<Map<String, dynamic>> post(String path, {Object? data});
}
