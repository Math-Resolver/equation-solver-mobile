import 'models/conversation_response.dart';

abstract class IChatAssistantRepositoryInterface {
  Future<List<String>> getAvailableTopics();

  Future<ConversationResponse> createConversation({required String topic});
}
