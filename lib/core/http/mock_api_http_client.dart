import 'dart:async';
import 'dart:math';

import 'http_client_interface.dart';
import 'http_exception.dart';

class MockApiHttpClient implements IHttpClientInterface {
  MockApiHttpClient({
    String scenario = '',
    int latencyMs = 800,
    int latencyJitterMs = 400,
    Random? random,
  }) : _scenarios = scenario
          .split(',')
          .map((item) => item.trim().toLowerCase())
          .where((item) => item.isNotEmpty)
          .toSet(),
       _latencyMs = latencyMs < 0 ? 0 : latencyMs,
       _latencyJitterMs = latencyJitterMs < 0 ? 0 : latencyJitterMs,
       _random = random ?? Random();

  final Set<String> _scenarios;
  final int _latencyMs;
  final int _latencyJitterMs;
  final Random _random;

  @override
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    await _simulateLatency();
    _throwIfScenarioError(method: 'GET', path: path);

    switch (path) {
      case '/v1/topics/available':
        return {
          'topics': 
            [
              'Logarithm', 
              'Linear Equations', 
              'Quadratic Equations',
              'Polygons',
              'Trigonomety',
              'Mean',
              'Simple Equations',
              'TABLE Equations',
              'ASA Equations',
              'DROP TABLE Equations',
              'DROP * FROM USERS',
              'SimplDORe SET',
              'ETSTES SET',
              'ESTSE TESTEE',
              'TESTSE Equations',
              'ETEST Equations',
              'Simple TESTE',
              'Simple TESTES',
              'Simple Equatdawadwaions',
              'Simple sasasdasda',
              'Simple asasa',
              'Simple ESAS',
              'Simples',
              ],
        };
      default:
        throw HttpException(statusCode: 404, message: 'Mock route not found');
    }
  }

  @override
  Future<Map<String, dynamic>> post(String path, {Object? data}) async {
    await _simulateLatency();

    final statusOverride = _extractStatusOverride(data);
    if (statusOverride != null) {
      throw HttpException(
        statusCode: statusOverride,
        message: 'Forced by request payload',
      );
    }

    _throwIfScenarioError(method: 'POST', path: path);

    switch (path) {
      case '/v1/auth/login':
      case '/v1/auth/register':
        return {
          'challenge': 'mock-challenge-token',
          'relyingParty': {'id': 'killmath', 'name': 'KillMath'},
          'user': {
            'id': 'mock-user-id',
            'name': 'mock-user',
            'displayName': 'Mock User',
          },
        };
      case '/v1/auth/login/finish':
      case '/v1/auth/register/finish':
        final shouldFailAuth = _hasScenario('auth_finish_401');
        if (shouldFailAuth) {
          throw const HttpException(statusCode: 401, message: 'Unauthorized');
        }
        return {
          'access_token': 'mock-access-token',
          'refresh_token': 'mock-refresh-token',
        };
      case '/v1/conversation':
        final topic = _extractString(data, 'topic').trim();
        if (topic.isEmpty) {
          throw const HttpException(
            statusCode: 400,
            message: 'Topic is required',
          );
        }
        return {
          'message': 'Mock explanation about $topic.',
          'example': 'Mock example for $topic: x + 2 = 5 => x = 3.',
        };
      case '/v1/equation/solve':
        final equation = _extractString(data, 'equation').trim();
        if (equation.isEmpty) {
          throw const HttpException(
            statusCode: 400,
            message: 'Equation is required',
          );
        }
        return {
          'result': 'x = 3',
          'steps': [
            {
              'rule': 'Subtract 4 from both sides',
              'before': '2x + 4 = 10',
              'after': '2x = 6',
            },
            {
              'rule': 'Divide both sides by 2',
              'before': '2x = 6',
              'after': 'x = 3',
            },
          ],
        };
      default:
        throw HttpException(statusCode: 404, message: 'Mock route not found');
    }
  }

  void _throwIfScenarioError({required String method, required String path}) {
    final routeKey = '${method.toLowerCase()}:$path';

    if (_hasScenario('all_401') || _hasScenario('$routeKey:401')) {
      throw const HttpException(statusCode: 401, message: 'Unauthorized');
    }
    if (_hasScenario('all_400') || _hasScenario('$routeKey:400')) {
      throw const HttpException(statusCode: 400, message: 'Bad request');
    }
    if (_hasScenario('all_502') || _hasScenario('$routeKey:502')) {
      throw const HttpException(statusCode: 502, message: 'Bad gateway');
    }

    if (_hasScenario('auth_401') && path.startsWith('/v1/auth/')) {
      throw const HttpException(statusCode: 401, message: 'Unauthorized');
    }
    if (_hasScenario('topics_502') && path == '/v1/topics/available') {
      throw const HttpException(statusCode: 502, message: 'Bad gateway');
    }
    if (_hasScenario('conversation_502') && path == '/v1/conversation') {
      throw const HttpException(statusCode: 502, message: 'Bad gateway');
    }
    if (_hasScenario('equation_400') && path == '/v1/equation/solve') {
      throw const HttpException(statusCode: 400, message: 'Bad request');
    }
    if (_hasScenario('equation_502') && path == '/v1/equation/solve') {
      throw const HttpException(statusCode: 502, message: 'Bad gateway');
    }
  }

  bool _hasScenario(String value) => _scenarios.contains(value.toLowerCase());

  int? _extractStatusOverride(Object? data) {
    if (data is! Map<String, dynamic>) {
      return null;
    }
    final status = data['__mockStatusCode'];
    if (status is int) {
      return status;
    }
    if (status is String) {
      return int.tryParse(status);
    }
    return null;
  }

  String _extractString(Object? data, String key) {
    if (data is! Map<String, dynamic>) {
      return '';
    }
    return (data[key] ?? '').toString();
  }

  Future<void> _simulateLatency() {
    final jitter = _latencyJitterMs > 0
        ? _random.nextInt(_latencyJitterMs + 1)
        : 0;
    final totalDelayMs = _latencyMs + jitter;
    if (totalDelayMs <= 0) {
      return Future<void>.value();
    }
    return Future<void>.delayed(Duration(milliseconds: totalDelayMs));
  }
}