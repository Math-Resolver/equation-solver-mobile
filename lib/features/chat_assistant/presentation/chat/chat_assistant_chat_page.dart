import 'package:equation_solver_mobile/dependencies.dart';
import 'package:equation_solver_mobile/core/localization/app_localization_scope.dart';
import 'package:equation_solver_mobile/core/localization/app_text_key.dart';
import 'package:equation_solver_mobile/features/chat_assistant/repository/chat_assistant_repository_interface.dart';
import 'package:equation_solver_mobile/features/chat_assistant/repository/models/conversation_response.dart';
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
  late final _repository =
      widget.repository ?? AppDependencies.instance.chatRepository;
  late final TextEditingController _topicController;
  ConversationResponse? _response;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _topicController = TextEditingController(text: widget.equation);
  }

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  Future<void> _sendTopic() async {
    final localeController = AppLocalizationScope.of(context);
    final topic = _topicController.text.trim();
    if (topic.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localeController.text(AppTextKey.chatTopicRequired)),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await _repository.createConversation(topic: topic);
      if (!mounted) return;
      setState(() => _response = response);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localeController.text(AppTextKey.chatConsultError)),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeController = AppLocalizationScope.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(localeController.text(AppTextKey.chatTitle))),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _topicController,
              decoration: InputDecoration(
                labelText: localeController.text(AppTextKey.chatTopicLabel),
                hintText: localeController.text(AppTextKey.chatTopicHint),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _isLoading ? null : _sendTopic,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(localeController.text(AppTextKey.chatSubmit)),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _response == null
                  ? Center(
                      child: Text(
                        localeController.text(AppTextKey.chatEmptyResponse),
                      ),
                    )
                  : Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _response!.message,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _response!.example,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
