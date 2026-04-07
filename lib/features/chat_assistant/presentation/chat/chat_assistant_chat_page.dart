import 'package:flutter/material.dart';

class ChatAssistantChatPage extends StatelessWidget {
  final String equation;

  const ChatAssistantChatPage({
    super.key,
    required this.equation,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Calculadora")),
      body: Center(
        child: Text(
          equation.isEmpty
              ? "Digite uma equação"
              : "Equação: $equation",
        ),
      ),
    );
  }
}