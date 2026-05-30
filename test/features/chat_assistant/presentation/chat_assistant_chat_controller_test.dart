import 'package:equation_solver_mobile/features/chat_assistant/presentation/chat/chat_assistant_chat_controller.dart';
import 'package:equation_solver_mobile/features/chat_assistant/repository/chat_assistant_repository_interface.dart';
import 'package:equation_solver_mobile/features/chat_assistant/repository/models/conversation_response.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeChatAssistantRepository implements IChatAssistantRepositoryInterface {
  FakeChatAssistantRepository({
    this.topics = const [],
    this.responses = const [],
    this.getTopicsError,
    this.createConversationErrors = const [],
  });

  final List<String> topics;
  final List<ConversationResponse> responses;
  final Object? getTopicsError;
  final List<Object?> createConversationErrors;

  int getAvailableTopicsCalls = 0;
  int createConversationCalls = 0;
  String? lastTopic;

  @override
  Future<List<String>> getAvailableTopics() async {
    getAvailableTopicsCalls++;
    if (getTopicsError != null) {
      throw getTopicsError!;
    }
    return topics;
  }

  @override
  Future<ConversationResponse> createConversation({required String topic}) async {
    createConversationCalls++;
    lastTopic = topic;
    if (createConversationCalls <= createConversationErrors.length &&
        createConversationErrors[createConversationCalls - 1] != null) {
      throw createConversationErrors[createConversationCalls - 1]!;
    }
    if (responses.isEmpty) {
      return const ConversationResponse(
        message: 'Explicacao breve',
        example: 'Exemplo pratico',
      );
    }
    if (createConversationCalls <= responses.length) {
      return responses[createConversationCalls - 1];
    }
    return responses.last;
  }
}

void main() {
  group('ChatAssistantChatController', () {
    test('loadTopics moves to initial state with loaded topics', () async {
      final repository = FakeChatAssistantRepository(
        topics: ['Logarithm', 'Linear Equations'],
      );
      final controller = ChatAssistantChatController(repository: repository);

      await controller.loadTopics();

      expect(controller.state, ChatAssistantViewState.initial);
      expect(controller.topics, ['Logarithm', 'Linear Equations']);
      expect(repository.getAvailableTopicsCalls, 1);
    });

    test('selectTopic adds user topic then bot messages', () async {
      final repository = FakeChatAssistantRepository(
        topics: ['Logarithm'],
        responses: const [
          ConversationResponse(
            message: 'Explicacao breve',
            example: 'Exemplo pratico',
          ),
        ],
      );
      final controller = ChatAssistantChatController(repository: repository);

      await controller.selectTopic('Logarithm');

      expect(controller.state, ChatAssistantViewState.conversationReady);
      expect(controller.selectedTopic, 'Logarithm');
      expect(controller.messages, hasLength(3));
      expect(controller.messages[0].text, 'Logarithm');
      expect(controller.messages[0].sender, ChatAssistantMessageSender.user);
      expect(controller.messages[1].text, 'Explicacao breve');
      expect(controller.messages[1].sender, ChatAssistantMessageSender.bot);
      expect(controller.messages[2].text, 'Exemplo pratico');
      expect(controller.messages[2].sender, ChatAssistantMessageSender.bot);
      expect(repository.createConversationCalls, 1);
    });

    test('requestMoreExample appends only example message', () async {
      final repository = FakeChatAssistantRepository(
        topics: ['Logarithm'],
        responses: const [
          ConversationResponse(
            message: 'Explicacao breve',
            example: 'Exemplo pratico 1',
          ),
          ConversationResponse(
            message: 'Outra explicacao',
            example: 'Exemplo pratico 2',
          ),
        ],
      );
      final controller = ChatAssistantChatController(repository: repository);

      await controller.selectTopic('Logarithm');
      await controller.requestMoreExample();

      expect(controller.state, ChatAssistantViewState.conversationReady);
      expect(controller.messages, hasLength(4));
      expect(controller.messages.last.text, 'Exemplo pratico 2');
      expect(controller.messages.last.sender, ChatAssistantMessageSender.bot);
      expect(repository.createConversationCalls, 2);
    });

    test('changeTopic keeps conversation and clears only selected topic', () async {
      final repository = FakeChatAssistantRepository(
        topics: ['Logarithm'],
        responses: const [
          ConversationResponse(
            message: 'Explicacao breve',
            example: 'Exemplo pratico',
          ),
        ],
      );
      final controller = ChatAssistantChatController(repository: repository);

      await controller.selectTopic('Logarithm');
      controller.changeTopic();

      expect(controller.state, ChatAssistantViewState.initial);
      expect(controller.selectedTopic, isNull);
      expect(controller.messages, hasLength(3));
    });

    test('requestMoreExample error keeps conversation context', () async {
      final repository = FakeChatAssistantRepository(
        topics: ['Logarithm'],
        responses: const [
          ConversationResponse(
            message: 'Explicacao breve',
            example: 'Exemplo pratico',
          ),
        ],
        createConversationErrors: [null, Exception('network error')],
      );
      final controller = ChatAssistantChatController(repository: repository);

      await controller.selectTopic('Logarithm');
      await controller.requestMoreExample();

      expect(controller.state, ChatAssistantViewState.error);
      expect(controller.selectedTopic, 'Logarithm');
      expect(controller.messages, hasLength(3));
    });
  });
}