import 'models/conversation_response.dart';

abstract class IChatAssistantRepositoryInterface {
  Future<ConversationResponse> createConversation({required String topic});
}
