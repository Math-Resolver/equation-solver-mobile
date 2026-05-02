class ConversationResponse {
  const ConversationResponse({required this.message, required this.example});

  final String message;
  final String example;

  factory ConversationResponse.fromJson(Map<String, dynamic> json) {
    return ConversationResponse(
      message: (json['message'] ?? '').toString(),
      example: (json['example'] ?? '').toString(),
    );
  }
}
