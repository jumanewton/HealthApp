// lib/models/chat_message.dart
enum MessageRole { user, ai }

class ChatMessage {
  final MessageRole role;
  final String message;
  final DateTime timestamp;

  ChatMessage({
    required this.role,
    required this.message,
    required this.timestamp,
  });
}