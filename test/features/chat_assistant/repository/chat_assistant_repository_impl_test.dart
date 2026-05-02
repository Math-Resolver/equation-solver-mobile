import 'package:equation_solver_mobile/features/chat_assistant/repository/chat_assistant_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_http_client.dart';

void main() {
  group('ChatAssistantRepositoryImpl', () {
    test('createConversation posts topic and parses response', () async {
      final httpClient = FakeHttpClient(
        handler: (_) async => {
          'message': 'A logarithm tells which exponent produces a value.',
          'example': 'log2(8) = 3 because 2^3 = 8.',
        },
      );

      final repository = ChatAssistantRepositoryImpl(httpClient: httpClient);

      final result = await repository.createConversation(topic: 'Logarithm');

      final request = httpClient.requests.single;
      expect(request.path, '/v1/conversation');
      expect(request.method, 'POST');
      expect(request.data, {'topic': 'Logarithm'});
      expect(
        result.message,
        'A logarithm tells which exponent produces a value.',
      );
      expect(result.example, 'log2(8) = 3 because 2^3 = 8.');
    });
  });
}