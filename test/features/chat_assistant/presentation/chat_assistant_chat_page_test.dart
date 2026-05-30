import 'package:equation_solver_mobile/features/chat_assistant/presentation/chat/chat_assistant_chat_page.dart';
import 'package:equation_solver_mobile/features/chat_assistant/repository/chat_assistant_repository_interface.dart';
import 'package:equation_solver_mobile/features/chat_assistant/repository/models/conversation_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeChatAssistantRepository implements IChatAssistantRepositoryInterface {
  FakeChatAssistantRepository({
    required this.topics,
    required this.responses,
    this.getTopicsError,
  });

  final List<String> topics;
  final List<ConversationResponse> responses;
  final Object? getTopicsError;

  int createConversationCalls = 0;

  @override
  Future<List<String>> getAvailableTopics() async {
    if (getTopicsError != null) {
      throw getTopicsError!;
    }
    return topics;
  }

  @override
  Future<ConversationResponse> createConversation({required String topic}) async {
    createConversationCalls++;
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
  group('ChatAssistantChatPage', () {
    testWidgets('renders header with Killbot and Fechar', (tester) async {
      final repository = FakeChatAssistantRepository(
        topics: ['Logarithm'],
        responses: const [
          ConversationResponse(
            message: 'Explicacao breve',
            example: 'Exemplo pratico',
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ChatAssistantChatPage(equation: '', repository: repository),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Killbot'), findsWidgets);
      expect(find.text('Fechar'), findsOneWidget);
    });

    testWidgets('renders topic suggestions after loading', (tester) async {
      final repository = FakeChatAssistantRepository(
        topics: ['Logarithm', 'Linear Equations'],
        responses: const [
          ConversationResponse(
            message: 'Explicacao breve',
            example: 'Exemplo pratico',
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ChatAssistantChatPage(equation: '', repository: repository),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('topic_suggestion_Logarithm')), findsOneWidget);
      expect(find.byKey(const Key('topic_suggestion_Linear Equations')), findsOneWidget);
    });

    testWidgets('shows conversation after choosing a topic', (tester) async {
      final repository = FakeChatAssistantRepository(
        topics: ['Logarithm'],
        responses: const [
          ConversationResponse(
            message: 'Explicacao breve',
            example: 'Exemplo pratico',
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ChatAssistantChatPage(equation: '', repository: repository),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('topic_suggestion_Logarithm')));
      await tester.pump(const Duration(seconds: 3));

      expect(find.text('Logarithm'), findsWidgets);
      expect(find.text('Explicacao breve'), findsOneWidget);
      expect(find.text('Exemplo pratico'), findsOneWidget);
      expect(find.text('Voce'), findsOneWidget);
      expect(find.text('Killbot'), findsWidgets);
      expect(find.text('Pedir mais exemplo'), findsOneWidget);
      expect(find.text('Trocar topico'), findsOneWidget);
      expect(find.byKey(const Key('chat_request_more_example_button')), findsOneWidget);
      expect(find.byKey(const Key('chat_change_topic_button')), findsOneWidget);
    });

    testWidgets('adds only an example when asking for one more', (tester) async {
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

      await tester.pumpWidget(
        MaterialApp(
          home: ChatAssistantChatPage(equation: '', repository: repository),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('topic_suggestion_Logarithm')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pedir mais exemplo'));
      await tester.pump(const Duration(seconds: 2));

      expect(find.text('Exemplo pratico 2'), findsOneWidget);
      expect(repository.createConversationCalls, 2);
    });

    testWidgets('keeps messages and opens topic suggestions when changing topic', (tester) async {
      final repository = FakeChatAssistantRepository(
        topics: ['Logarithm', 'Algebra'],
        responses: const [
          ConversationResponse(
            message: 'Explicacao breve',
            example: 'Exemplo pratico',
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ChatAssistantChatPage(equation: '', repository: repository),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('topic_suggestion_Logarithm')));
      await tester.pump(const Duration(seconds: 3));
      await tester.tap(find.text('Trocar topico'));
      await tester.pumpAndSettle();

      expect(find.text('Explicacao breve'), findsOneWidget);
      expect(find.text('Logarithm'), findsWidgets);
      expect(find.byKey(const Key('topic_suggestion_Logarithm')), findsOneWidget);
      expect(find.byKey(const Key('topic_suggestion_Algebra')), findsOneWidget);
      expect(find.byKey(const Key('topic_suggestions_footer')), findsOneWidget);
    });

    testWidgets('appends messages after selecting a new topic', (tester) async {
      final repository = FakeChatAssistantRepository(
        topics: ['Logarithm', 'Algebra'],
        responses: const [
          ConversationResponse(
            message: 'Explicacao breve',
            example: 'Exemplo pratico',
          ),
          ConversationResponse(
            message: 'Nova explicacao Algebra',
            example: 'Novo exemplo Algebra',
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ChatAssistantChatPage(equation: '', repository: repository),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('topic_suggestion_Logarithm')));
      await tester.pump(const Duration(seconds: 3));
      await tester.tap(find.text('Trocar topico'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('topic_suggestion_Algebra')));
      await tester.pump(const Duration(seconds: 4));

      expect(find.text('Algebra'), findsWidgets);
      expect(find.text('Explicacao breve'), findsOneWidget);
      expect(find.text('Nova explicacao Algebra'), findsOneWidget);
      expect(find.text('Novo exemplo Algebra'), findsOneWidget);
    });

    testWidgets('shows error feedback when loading topics fails', (tester) async {
      final repository = FakeChatAssistantRepository(
        topics: const [],
        responses: const [],
        getTopicsError: Exception('network error'),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ChatAssistantChatPage(equation: '', repository: repository),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Nao foi possivel consultar o assistente.'), findsOneWidget);
      expect(find.text('Tentar topicos novamente'), findsOneWidget);
    });

    testWidgets('shows suggestions inside bottom blue footer', (tester) async {
      final repository = FakeChatAssistantRepository(
        topics: ['Logarithm'],
        responses: const [
          ConversationResponse(
            message: 'Explicacao breve',
            example: 'Exemplo pratico',
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ChatAssistantChatPage(equation: '', repository: repository),
        ),
      );
      await tester.pumpAndSettle();

      final footer = tester.widget<Container>(
        find.byKey(const Key('topic_suggestions_footer')),
      );
      expect(footer.color, const Color(0xFF86A8C8));
      expect(
        find.byKey(const Key('topic_suggestions_horizontal_scroll')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('topic_suggestion_Logarithm')), findsOneWidget);
    });

    testWidgets('groups topics into columns of three', (tester) async {
      final repository = FakeChatAssistantRepository(
        topics: const [
          'T1',
          'T2',
          'T3',
          'T4',
          'T5',
          'T6',
          'T7',
        ],
        responses: const [
          ConversationResponse(
            message: 'Explicacao breve',
            example: 'Exemplo pratico',
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ChatAssistantChatPage(equation: '', repository: repository),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('topic_suggestions_column_0')), findsOneWidget);
      expect(find.byKey(const Key('topic_suggestions_column_1')), findsOneWidget);
      expect(find.byKey(const Key('topic_suggestions_column_2')), findsOneWidget);
      expect(find.byKey(const Key('topic_suggestions_column_3')), findsNothing);
      expect(find.byKey(const Key('topic_suggestion_T1')), findsOneWidget);
      expect(find.byKey(const Key('topic_suggestion_T7')), findsOneWidget);
    });

    testWidgets('reveals bot message gradually while typing', (tester) async {
      final repository = FakeChatAssistantRepository(
        topics: ['Logarithm'],
        responses: const [
          ConversationResponse(
            message: 'Mensagem longa para animar digitacao',
            example: 'Exemplo pratico',
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ChatAssistantChatPage(equation: '', repository: repository),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('topic_suggestion_Logarithm')));
      await tester.pump(const Duration(milliseconds: 120));

      expect(find.text('Mensagem longa para animar digitacao'), findsNothing);

      await tester.pump(const Duration(seconds: 4));

      expect(find.text('Mensagem longa para animar digitacao'), findsOneWidget);
    });
  });
}