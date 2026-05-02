import 'package:equation_solver_mobile/core/http/http_client_interface.dart';

import 'chat_assistant_repository_interface.dart';
import 'models/conversation_response.dart';

class ChatAssistantRepositoryImpl implements IChatAssistantRepositoryInterface {
  ChatAssistantRepositoryImpl({required IHttpClientInterface httpClient})
      : _httpClient = httpClient;

  final IHttpClientInterface _httpClient;

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
