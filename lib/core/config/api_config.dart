abstract final class ApiConfig {
  static const String devBaseUrl = 'http://127.0.0.1:8000';
  static const String baseUrl = devBaseUrl;

  // Enable with: --dart-define=USE_API_MOCK=true
  static const bool useApiMock = bool.fromEnvironment('USE_API_MOCK');

  // Optional: --dart-define=MOCK_API_SCENARIO=auth_401,equation_400
  static const String mockApiScenario = String.fromEnvironment(
    'MOCK_API_SCENARIO',
    defaultValue: '',
  );

  // Optional: --dart-define=MOCK_API_LATENCY_MS=800
  static const int mockApiLatencyMs = int.fromEnvironment(
    'MOCK_API_LATENCY_MS',
    defaultValue: 800,
  );

  // Optional: --dart-define=MOCK_API_LATENCY_JITTER_MS=400
  static const int mockApiLatencyJitterMs = int.fromEnvironment(
    'MOCK_API_LATENCY_JITTER_MS',
    defaultValue: 400,
  );
}
