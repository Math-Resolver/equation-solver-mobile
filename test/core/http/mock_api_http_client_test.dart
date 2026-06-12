import 'package:equation_solver_mobile/core/http/http_exception.dart';
import 'package:equation_solver_mobile/core/http/mock_api_http_client.dart';
import 'package:flutter_test/flutter_test.dart';

MockApiHttpClient _client({String scenario = ''}) {
  return MockApiHttpClient(
    scenario: scenario,
    latencyMs: 0,
    latencyJitterMs: 0,
  );
}

void main() {
  group('MockApiHttpClient success responses', () {
    test('GET /v1/topics/available returns topics', () async {
      final client = _client();

      final data = await client.get('/v1/topics/available');

      expect(data['topics'], isA<List<dynamic>>());
      expect((data['topics'] as List<dynamic>).isNotEmpty, isTrue);
    });

    test('POST /v1/auth/login returns auth challenge', () async {
      final client = _client();

      final data = await client.post('/v1/auth/login', data: const {});

      expect((data['challenge'] ?? '').toString().isNotEmpty, isTrue);
      expect(data['relyingParty'], isA<Map<String, dynamic>>());
      expect(data['user'], isA<Map<String, dynamic>>());
    });

    test('POST /v1/auth/login/finish returns tokens', () async {
      final client = _client();

      final data = await client.post(
        '/v1/auth/login/finish',
        data: {'credential': 'mock-credential'},
      );

      expect((data['access_token'] ?? '').toString().isNotEmpty, isTrue);
      expect((data['refresh_token'] ?? '').toString().isNotEmpty, isTrue);
    });

    test('POST /v1/auth/register returns auth challenge', () async {
      final client = _client();

      final data = await client.post('/v1/auth/register', data: const {});

      expect((data['challenge'] ?? '').toString().isNotEmpty, isTrue);
      expect(data['relyingParty'], isA<Map<String, dynamic>>());
      expect(data['user'], isA<Map<String, dynamic>>());
    });

    test('POST /v1/auth/register/finish returns tokens', () async {
      final client = _client();

      final data = await client.post(
        '/v1/auth/register/finish',
        data: {'credential': 'mock-credential'},
      );

      expect((data['access_token'] ?? '').toString().isNotEmpty, isTrue);
      expect((data['refresh_token'] ?? '').toString().isNotEmpty, isTrue);
    });

    test('POST /v1/conversation returns message and example', () async {
      final client = _client();

      final data = await client.post(
        '/v1/conversation',
        data: {'topic': 'Logarithm'},
      );

      expect((data['message'] ?? '').toString().contains('Logarithm'), isTrue);
      expect((data['example'] ?? '').toString().isNotEmpty, isTrue);
    });

    test('POST /v1/equation/solve returns result and steps', () async {
      final client = _client();

      final data = await client.post(
        '/v1/equation/solve',
        data: {'equation': 'x + 2 = 5', 'showSteps': true},
      );

      expect((data['result'] ?? '').toString().isNotEmpty, isTrue);
      expect(data['steps'], isA<List<dynamic>>());
      final steps = data['steps'] as List<dynamic>;
      expect(steps.length, greaterThanOrEqualTo(2));
      final firstStep = steps.first as Map<String, dynamic>;
      expect((firstStep['rule'] ?? '').toString().isNotEmpty, isTrue);
      expect((firstStep['before'] ?? '').toString().isNotEmpty, isTrue);
      expect((firstStep['after'] ?? '').toString().isNotEmpty, isTrue);
    });
  });

  group('MockApiHttpClient error scenarios', () {
    test('returns 400 for empty conversation topic', () async {
      final client = _client();

      expect(
        () => client.post('/v1/conversation', data: {'topic': ''}),
        throwsA(
          isA<HttpException>().having((e) => e.statusCode, 'statusCode', 400),
        ),
      );
    });

    test('returns 400 for empty equation', () async {
      final client = _client();

      expect(
        () => client.post('/v1/equation/solve', data: {'equation': ''}),
        throwsA(
          isA<HttpException>().having((e) => e.statusCode, 'statusCode', 400),
        ),
      );
    });

    test('supports scenario auth_401', () async {
      final client = _client(scenario: 'auth_401');

      expect(
        () => client.post('/v1/auth/login', data: const {}),
        throwsA(
          isA<HttpException>().having((e) => e.statusCode, 'statusCode', 401),
        ),
      );
    });

    test('supports scenario topics_502', () async {
      final client = _client(scenario: 'topics_502');

      expect(
        () => client.get('/v1/topics/available'),
        throwsA(
          isA<HttpException>().having((e) => e.statusCode, 'statusCode', 502),
        ),
      );
    });

    test('supports scenario equation_400', () async {
      final client = _client(scenario: 'equation_400');

      expect(
        () => client.post(
          '/v1/equation/solve',
          data: {'equation': 'x + 2 = 5'},
        ),
        throwsA(
          isA<HttpException>().having((e) => e.statusCode, 'statusCode', 400),
        ),
      );
    });

    test('supports forcing status code by payload', () async {
      final client = _client();

      expect(
        () => client.post(
          '/v1/equation/solve',
          data: {'equation': 'x + 2 = 5', '__mockStatusCode': 502},
        ),
        throwsA(
          isA<HttpException>().having((e) => e.statusCode, 'statusCode', 502),
        ),
      );
    });
  });

  group('MockApiHttpClient latency', () {
    test('applies fixed latency when jitter is zero', () async {
      final client = MockApiHttpClient(latencyMs: 60, latencyJitterMs: 0);
      final watch = Stopwatch()..start();

      await client.get('/v1/topics/available');

      watch.stop();
      expect(watch.elapsedMilliseconds, greaterThanOrEqualTo(50));
    });

    test('applies latency before error responses too', () async {
      final client = MockApiHttpClient(
        scenario: 'topics_502',
        latencyMs: 60,
        latencyJitterMs: 0,
      );
      final watch = Stopwatch()..start();

      await expectLater(
        () => client.get('/v1/topics/available'),
        throwsA(
          isA<HttpException>().having((e) => e.statusCode, 'statusCode', 502),
        ),
      );

      watch.stop();
      expect(watch.elapsedMilliseconds, greaterThanOrEqualTo(50));
    });
  });
}