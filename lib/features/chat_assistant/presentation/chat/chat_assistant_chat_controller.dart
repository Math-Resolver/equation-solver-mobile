import 'package:equation_solver_mobile/features/chat_assistant/repository/chat_assistant_repository_interface.dart';
import 'package:flutter/foundation.dart';

enum ChatAssistantViewState {
  initial,
  loadingTopic,
  conversationReady,
  loadingMoreExample,
  error,
}

enum ChatAssistantMessageType { userTopic, explanation, example }

enum ChatAssistantMessageSender { user, bot }

class ChatAssistantMessage {
  const ChatAssistantMessage({
    required this.text,
    required this.type,
    required this.sender,
  });

  final String text;
  final ChatAssistantMessageType type;
  final ChatAssistantMessageSender sender;
}

class ChatAssistantChatController extends ChangeNotifier {
  ChatAssistantChatController({required IChatAssistantRepositoryInterface repository})
      : _repository = repository;

  final IChatAssistantRepositoryInterface _repository;

  ChatAssistantViewState _state = ChatAssistantViewState.initial;
  List<String> _topics = const [];
  List<ChatAssistantMessage> _messages = const [];
  String? _selectedTopic;
  Object? _error;

  ChatAssistantViewState get state => _state;
  List<String> get topics => _topics;
  List<ChatAssistantMessage> get messages => _messages;
  String? get selectedTopic => _selectedTopic;
  Object? get error => _error;

  bool get hasConversation => _messages.isNotEmpty;

  Future<void> loadTopics() async {
    _setState(ChatAssistantViewState.loadingTopic);
    try {
      _topics = await _repository.getAvailableTopics();
      _selectedTopic = null;
      _messages = const [];
      _clearError();
      _setState(ChatAssistantViewState.initial);
    } catch (error) {
      _setError(error);
    }
  }

  Future<void> selectTopic(String topic) async {
    _selectedTopic = topic;
    _messages = [
      ..._messages,
      ChatAssistantMessage(
        text: topic,
        type: ChatAssistantMessageType.userTopic,
        sender: ChatAssistantMessageSender.user,
      ),
    ];
    _setState(ChatAssistantViewState.loadingTopic);
    try {
      final response = await _repository.createConversation(topic: topic);
      _messages = [
        ..._messages,
        ChatAssistantMessage(
          text: response.message,
          type: ChatAssistantMessageType.explanation,
          sender: ChatAssistantMessageSender.bot,
        ),
        ChatAssistantMessage(
          text: response.example,
          type: ChatAssistantMessageType.example,
          sender: ChatAssistantMessageSender.bot,
        ),
      ];
      _clearError();
      _setState(ChatAssistantViewState.conversationReady);
    } catch (error) {
      _setError(error);
    }
  }

  Future<void> requestMoreExample() async {
    final topic = _selectedTopic;
    if (topic == null || topic.isEmpty) {
      return;
    }

    _setState(ChatAssistantViewState.loadingMoreExample);
    try {
      final response = await _repository.createConversation(topic: topic);
      _messages = [
        ..._messages,
        ChatAssistantMessage(
          text: response.example,
          type: ChatAssistantMessageType.example,
          sender: ChatAssistantMessageSender.bot,
        ),
      ];
      _clearError();
      _setState(ChatAssistantViewState.conversationReady);
    } catch (error) {
      _setError(error);
    }
  }

  void changeTopic() {
    _selectedTopic = null;
    _clearError();
    _setState(ChatAssistantViewState.initial);
  }

  void _setState(ChatAssistantViewState state) {
    if (_state == state) {
      notifyListeners();
      return;
    }
    _state = state;
    notifyListeners();
  }

  void _setError(Object error) {
    _error = error;
    _state = ChatAssistantViewState.error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}