import 'package:equation_solver_mobile/core/http/http_client_interface.dart';

import 'chat_assistant_repository_interface.dart';
import 'models/conversation_response.dart';

class ChatAssistantRepositoryImpl implements IChatAssistantRepositoryInterface {
  ChatAssistantRepositoryImpl({required IHttpClientInterface httpClient})
      : _httpClient = httpClient;

  final IHttpClientInterface _httpClient;

  @override
  Future<List<String>> getAvailableTopics() async {
    final data = await _httpClient.get('/v1/topics/available');
    final topics = (data['topics'] as List<dynamic>? ?? const <dynamic>[]);
    return topics
        .whereType<String>()
        .toList(growable: false);
  }

  @override
  Future<ConversationResponse> createConversation({
    required String topic,
  }) async {
    final data = await _httpClient.post(
      '/v1/conversation',
      data: {'topic': topic},
    );
    return ConversationResponse.fromJson(data);
  }
}
