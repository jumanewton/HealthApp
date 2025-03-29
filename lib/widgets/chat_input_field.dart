// lib/features/chat/views/widgets/chat_input_field.dart
import 'package:flutter/material.dart';
import 'package:healthmate/providers/chat_provider.dart';
import 'package:provider/provider.dart';


class ChatInputField extends StatefulWidget {
  const ChatInputField({super.key});

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final chatProvider = context.read<ChatProvider>();
    if (_controller.text.trim().isNotEmpty) {
      chatProvider.sendMessage(_controller.text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              maxLines: 3,
              minLines: 1,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: 'Type your health-related question...',
                border: const OutlineInputBorder(),
                suffixIcon: chatProvider.isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
              ),
              enabled: !chatProvider.isLoading,
              onSubmitted: (_) {
                if (!chatProvider.isLoading && _controller.text.isNotEmpty) {
                  _sendMessage();
                }
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            color: Theme.of(context).primaryColor,
            onPressed: chatProvider.isLoading
                ? null
                : () {
                    if (_controller.text.isNotEmpty) {
                      _sendMessage();
                    }
                  },
          ),
        ],
      ),
    );
  }
}