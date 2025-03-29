// lib/features/chat/views/chat_page.dart
import 'package:flutter/material.dart';
import 'package:healthmate/widgets/chat_input_field.dart';
import 'package:healthmate/widgets/message_bubble.dart';
import 'package:provider/provider.dart';

import '../providers/chat_provider.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('HealthMate AI'),
        actions: [
          if (chatProvider.isLoading)
            IconButton(
              icon: const Icon(Icons.stop),
              onPressed: () => chatProvider.stopGeneration(),
              tooltip: 'Stop generation',
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(16.0),
              itemCount: chatProvider.messages.length,
              itemBuilder: (context, index) {
                return MessageBubble(message: chatProvider.messages[index]);
              },
            ),
          ),
          if (chatProvider.isLoading) const LinearProgressIndicator(),
          const ChatInputField(),
        ],
      ),
    );
  }
}