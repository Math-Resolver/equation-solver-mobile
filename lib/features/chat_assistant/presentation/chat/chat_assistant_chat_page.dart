import 'dart:async';

import 'package:equation_solver_mobile/dependencies.dart';
import 'package:equation_solver_mobile/core/localization/app_localization_scope.dart';
import 'package:equation_solver_mobile/core/localization/app_text_key.dart';
import 'package:equation_solver_mobile/drawables/app_colors.dart';
import 'package:equation_solver_mobile/drawables/app_top_bar_text_styles.dart';
import 'package:equation_solver_mobile/features/chat_assistant/presentation/chat/chat_assistant_chat_controller.dart';
import 'package:equation_solver_mobile/features/chat_assistant/repository/chat_assistant_repository_interface.dart';
import 'package:flutter/material.dart';

class ChatAssistantChatPage extends StatefulWidget {
  final String equation;
  final IChatAssistantRepositoryInterface? repository;

  const ChatAssistantChatPage({
    super.key,
    required this.equation,
    this.repository,
  });

  @override
  State<ChatAssistantChatPage> createState() => _ChatAssistantChatPageState();
}

class _ChatAssistantChatPageState extends State<ChatAssistantChatPage> {
  static const Duration _typingTick = Duration(milliseconds: 35);

  late final ChatAssistantChatController _controller;
  final Map<int, int> _visibleCharsByMessageIndex = {};
  final List<int> _typingQueue = [];
  Timer? _typingTimer;
  int _typingMessageIndex = -1;
  int _lastMessageCount = 0;

  @override
  void initState() {
    super.initState();
    final repository =
        widget.repository ?? AppDependencies.instance.chatRepository;
    _controller = ChatAssistantChatController(repository: repository);
    _controller.addListener(_onControllerChanged);
    _controller.loadTopics();
  }

  @override
  void dispose() {
    _stopTypingAnimation();
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    _syncTypingAnimationState();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(child: _buildBody(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final locale = AppLocalizationScope.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          Center(
            child: Text(
              locale.text(AppTextKey.cameraChatbot),
              style: AppTopBarTextStyles.title(color: Colors.black),
            ),
          ),
          Positioned(
            right: 0,
            child: GestureDetector(
              onTap: () => Navigator.of(context).canPop()
                  ? Navigator.of(context).pop()
                  : Navigator.of(context).pushReplacementNamed('/camera'),
              child: Text(
                locale.text(AppTextKey.calculatorClose),
                style: AppTopBarTextStyles.action(color: AppColors.selected),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final showConversation = _controller.hasConversation;
    final isSelectingNewTopic = showConversation && _controller.selectedTopic == null;

    if (_controller.state == ChatAssistantViewState.loadingTopic &&
        !showConversation &&
        _controller.topics.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!showConversation) {
      return _buildTopicSuggestions(context);
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_controller.state == ChatAssistantViewState.error)
            _buildErrorBanner(context),
          if (_controller.state == ChatAssistantViewState.loadingTopic)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: LinearProgressIndicator(),
            ),
          Expanded(child: _buildConversationList()),
          if (!isSelectingNewTopic) const SizedBox(height: 12),
          if (!isSelectingNewTopic &&
              _controller.state == ChatAssistantViewState.loadingMoreExample)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: LinearProgressIndicator(),
            ),
          if (!isSelectingNewTopic)
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton(
                  key: const Key('chat_request_more_example_button'),
                  onPressed:
                      _controller.state == ChatAssistantViewState.loadingMoreExample
                      ? null
                      : _controller.requestMoreExample,
                  style: _chipButtonStyle(),
                  child: Text(
                    AppLocalizationScope.of(context).text(
                      AppTextKey.chatRequestMoreExample,
                    ),
                  ),
                ),
                FilledButton(
                  key: const Key('chat_change_topic_button'),
                  onPressed: _controller.changeTopic,
                  style: _chipButtonStyle(),
                  child: Text(
                    AppLocalizationScope.of(context).text(
                      AppTextKey.chatChangeTopic,
                    ),
                  ),
                ),
              ],
            ),
          if (isSelectingNewTopic)
            _buildTopicSuggestionsFooter(
              context,
              isLoading: _controller.state == ChatAssistantViewState.loadingTopic,
            ),
        ],
      ),
    );
  }

  Widget _buildTopicSuggestions(BuildContext context) {
    final locale = AppLocalizationScope.of(context);
    final isLoading = _controller.state == ChatAssistantViewState.loadingTopic;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_controller.state == ChatAssistantViewState.error)
                _buildErrorBanner(context),
              if (isLoading) const LinearProgressIndicator(),
            ],
          ),
        ),
        Expanded(
          child: isLoading
              ? const SizedBox.shrink()
              : Center(
                  child: Text(
                    locale.text(AppTextKey.chatEmptyResponse),
                    textAlign: TextAlign.center,
                  ),
                ),
        ),
        _buildTopicSuggestionsFooter(context, isLoading: isLoading),
      ],
    );
  }

  Widget _buildTopicSuggestionsFooter(
    BuildContext context, {
    required bool isLoading,
  }) {
    final locale = AppLocalizationScope.of(context);
    return Container(
      key: const Key('topic_suggestions_footer'),
      color: const Color(0xFF86A8C8),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_controller.state == ChatAssistantViewState.error &&
                  !_controller.hasConversation)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: FilledButton.tonal(
                    onPressed: _controller.loadTopics,
                    child: Text(locale.text(AppTextKey.chatRetryTopics)),
                  ),
                ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 160),
                child: SingleChildScrollView(
                  key: const Key('topic_suggestions_horizontal_scroll'),
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _chunkTopics(_controller.topics, 3)
                        .asMap()
                        .entries
                        .map(
                          (entry) => Padding(
                            key: Key('topic_suggestions_column_${entry.key}'),
                            padding: const EdgeInsets.only(right: 10),
                            child: SizedBox(
                              width: 220,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisSize: MainAxisSize.min,
                                children: entry.value
                                    .map(
                                      (topic) => Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 8,
                                        ),
                                        child: FilledButton(
                                          key: Key('topic_suggestion_$topic'),
                                          onPressed: isLoading
                                              ? null
                                              : () => _controller.selectTopic(topic),
                                          style: _chipButtonStyle(),
                                          child: Text(topic),
                                        ),
                                      ),
                                    )
                                    .toList(growable: false),
                              ),
                            ),
                          ),
                        )
                        .toList(growable: false),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConversationList() {
    return ListView.separated(
      itemCount: _controller.messages.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final message = _controller.messages[index];
        final isUser = message.sender == ChatAssistantMessageSender.user;
        final fullText = message.text;
        final visibleLength = _visibleCharsByMessageIndex[index] ?? fullText.length;
        final safeVisibleLength = visibleLength.clamp(0, fullText.length).toInt();
        final visibleText = fullText.substring(0, safeVisibleLength);

        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.8,
            ),
            child: Column(
              crossAxisAlignment: isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  isUser ? 'Voce' : 'Killbot',
                  style: TextStyle(
                    color: isUser ? AppColors.selected : const Color(0xFF486A8A),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  decoration: BoxDecoration(
                    color: isUser ? AppColors.selected : const Color(0xFFEAF3FB),
                    borderRadius: BorderRadius.circular(14),
                    border: isUser
                        ? null
                        : Border.all(color: const Color(0xFF9BB8D1)),
                  ),
                  padding: const EdgeInsets.all(14),
                  child: Text(
                    visibleText,
                    style: TextStyle(
                      color: isUser ? Colors.white : const Color(0xFF153A62),
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  ButtonStyle _chipButtonStyle() {
    return FilledButton.styleFrom(
      backgroundColor: const Color(0xFF0E4F95),
      foregroundColor: Colors.white,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      minimumSize: const Size(0, 36),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  List<List<String>> _chunkTopics(List<String> topics, int chunkSize) {
    if (topics.isEmpty) {
      return const <List<String>>[];
    }

    final chunks = <List<String>>[];
    for (var i = 0; i < topics.length; i += chunkSize) {
      final end = (i + chunkSize).clamp(0, topics.length).toInt();
      chunks.add(topics.sublist(i, end));
    }
    return chunks;
  }

  void _syncTypingAnimationState() {
    final messages = _controller.messages;

    if (messages.isEmpty) {
      _lastMessageCount = 0;
      _visibleCharsByMessageIndex.clear();
      _typingQueue.clear();
      _stopTypingAnimation();
      return;
    }

    if (messages.length < _lastMessageCount) {
      _visibleCharsByMessageIndex.clear();
      _typingQueue.clear();
      _stopTypingAnimation();
      _lastMessageCount = 0;
    }

    for (var i = 0; i < _lastMessageCount && i < messages.length; i++) {
      _visibleCharsByMessageIndex[i] = messages[i].text.length;
    }

    if (messages.length > _lastMessageCount) {
      for (var i = _lastMessageCount; i < messages.length; i++) {
        final message = messages[i];
        if (message.sender == ChatAssistantMessageSender.bot) {
          _visibleCharsByMessageIndex[i] = 0;
          _typingQueue.add(i);
        } else {
          _visibleCharsByMessageIndex[i] = message.text.length;
        }
      }
    }

    _lastMessageCount = messages.length;
    _startTypingAnimationIfNeeded();
  }

  void _startTypingAnimationIfNeeded() {
    if (_typingTimer != null || _typingQueue.isEmpty) {
      return;
    }

    _typingMessageIndex = _typingQueue.removeAt(0);
    _typingTimer = Timer.periodic(_typingTick, (timer) {
      if (!mounted) {
        _stopTypingAnimation();
        return;
      }

      final messageIndex = _typingMessageIndex;
      if (messageIndex < 0 || messageIndex >= _controller.messages.length) {
        _stopTypingAnimation();
        _startTypingAnimationIfNeeded();
        return;
      }

      final targetLength = _controller.messages[messageIndex].text.length;
      final currentLength = _visibleCharsByMessageIndex[messageIndex] ?? 0;

      if (currentLength >= targetLength) {
        _visibleCharsByMessageIndex[messageIndex] = targetLength;
        _stopTypingAnimation();
        _startTypingAnimationIfNeeded();
        if (mounted) {
          setState(() {});
        }
        return;
      }

      _visibleCharsByMessageIndex[messageIndex] = currentLength + 1;
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _stopTypingAnimation() {
    _typingTimer?.cancel();
    _typingTimer = null;
    _typingMessageIndex = -1;
  }

  Widget _buildErrorBanner(BuildContext context) {
    final locale = AppLocalizationScope.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE8E8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC13D3D)),
      ),
      child: Text(
        locale.text(AppTextKey.chatConsultError),
        style: const TextStyle(color: Color(0xFFC13D3D)),
      ),
    );
  }
}
