// lib/features/chat/views/widgets/message_bubble.dart
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:healthmate/models/chat_message.dart';


class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;
    final color = isUser ? Colors.blue[100] : Colors.green[100];
    final alignment = isUser ? Alignment.centerRight : Alignment.centerLeft;

    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8.0),
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isUser ? 'You' : 'HealthMate',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isUser ? Colors.blue[800] : Colors.green[800],
                ),
              ),
              const SizedBox(height: 4),
              MarkdownBody(
                data: message.message,
                styleSheet: MarkdownStyleSheet(
                  p: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}