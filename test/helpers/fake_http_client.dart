import 'package:equation_solver_mobile/core/http/http_client_interface.dart';

class FakeHttpRequest {
  const FakeHttpRequest({
    required this.method,
    required this.path,
    this.data,
    this.queryParameters,
  });

  final String method;
  final String path;
  final Object? data;
  final Map<String, dynamic>? queryParameters;
}

typedef FakeHttpHandler =
    Future<Map<String, dynamic>> Function(FakeHttpRequest request);

class FakeHttpClient implements IHttpClientInterface {
  FakeHttpClient({required FakeHttpHandler handler}) : _handler = handler;

  final FakeHttpHandler _handler;
  final List<FakeHttpRequest> requests = [];

  @override
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    final request = FakeHttpRequest(
      method: 'GET',
      path: path,
      queryParameters: queryParameters,
    );
    requests.add(request);
    return _handler(request);
  }

  @override
  Future<Map<String, dynamic>> post(String path, {Object? data}) {
    final request = FakeHttpRequest(method: 'POST', path: path, data: data);
    requests.add(request);
    return _handler(request);
  }
}
