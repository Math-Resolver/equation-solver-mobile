import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

typedef AdapterHandler =
    Future<FakeAdapterResponse> Function(RequestOptions options);

class FakeAdapterResponse {
  const FakeAdapterResponse({
    required this.statusCode,
    required this.data,
    this.headers = const <String, List<String>>{
      Headers.contentTypeHeader: <String>[Headers.jsonContentType],
    },
  });

  final int statusCode;
  final Object? data;
  final Map<String, List<String>> headers;
}

class FakeHttpClientAdapter implements HttpClientAdapter {
  FakeHttpClientAdapter({required AdapterHandler handler}) : _handler = handler;

  final AdapterHandler _handler;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final response = await _handler(options);
    final payload = jsonEncode(response.data ?? <String, Object?>{});
    return ResponseBody.fromString(
      payload,
      response.statusCode,
      headers: response.headers,
    );
  }
}
