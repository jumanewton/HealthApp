import 'package:healthmate/models/chat_message.dart';
import 'package:uuid/uuid.dart';


class Conversation {
  final String id;
  String title; 
  final DateTime createdAt;
  DateTime lastUpdatedAt;
  List<ChatMessage> messages;

  Conversation({
    String? id,
    required this.title,
    DateTime? createdAt,
    DateTime? lastUpdatedAt,
    required this.messages,
  }) : 
    id = id ?? const Uuid().v4(),
    createdAt = createdAt ?? DateTime.now(),
    lastUpdatedAt = lastUpdatedAt ?? DateTime.now();

  // Generate a title from the first message if none is provided
  static String generateTitle(List<ChatMessage> messages) {
    if (messages.isEmpty) return "New conversation";
    
    // Find the first user message
    for (final msg in messages) {
      if (msg.isUser) {
        // Use the first 30 characters as the title
        String text = msg.message.trim();
        if (text.length > 30) {
          return "${text.substring(0, 27)}...";
        }
        return text;
      }
    }
    
    return "New conversation";
  }

  // Convert conversation to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      'lastUpdatedAt': lastUpdatedAt.toIso8601String(),
      'messages': messages.map((m) => m.toJson()).toList(),
    };
  }

  // Create conversation from JSON
  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'],
      title: json['title'],
      createdAt: DateTime.parse(json['createdAt']),
      lastUpdatedAt: DateTime.parse(json['lastUpdatedAt']),
      messages: (json['messages'] as List)
          .map((m) => ChatMessage.fromJson(m))
          .toList(),
    );
  }
}