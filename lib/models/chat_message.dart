enum MessageRole { user, ai }

class ChatMessage {
  final MessageRole role;
  String message;
  final DateTime timestamp;
  bool isLoading;

  ChatMessage({
    required this.role,
    required this.message,
    required this.timestamp,
    this.isLoading = false,
  });

  bool get isUser => role == MessageRole.user;
  bool get isAi => role == MessageRole.ai;
  
  // Convert message to JSON
  Map<String, dynamic> toJson() {
    return {
      'role': role.toString().split('.').last,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'isLoading': isLoading,
    };
  }
  
  // Create message from JSON
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      role: json['role'] == 'user' ? MessageRole.user : MessageRole.ai,
      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']),
      isLoading: json['isLoading'] ?? false,
    );
  }
}