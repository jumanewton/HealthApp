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
    final brightness = Theme.of(context).brightness;
    final iconColor = brightness == Brightness.dark
        ? Colors.greenAccent
        : Theme.of(context).primaryColor;

    // Icon size constant
    const double iconSize = 28.0;

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
          // Add horizontal spacing between TextField and button
          const SizedBox(width: 8),
          // Enhanced send button with increased tap area
          Container(
            decoration: BoxDecoration(
              color: chatProvider.isLoading
                  ? Colors.transparent
                  : Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: IconButton(
              icon: Icon(Icons.send, size: iconSize),
              padding: const EdgeInsets.all(12.0),
              constraints: const BoxConstraints(),
              color: chatProvider.isLoading
                  ? iconColor.withOpacity(0.5)
                  : iconColor,
              onPressed: chatProvider.isLoading
                  ? null
                  : () {
                      if (_controller.text.isNotEmpty) {
                        _sendMessage();
                      }
                    },
            ),
          ),
        ],
      ),
    );
  }
}
