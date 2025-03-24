import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

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

class OllamaService {
  final String baseUrl;

  OllamaService({this.baseUrl = 'http://10.0.2.2:11434/api/generate'});

  Future<String> generateResponse(String message) async {
    try {
      final prompt = '''
You are a helpful AI healthcare assistant named HealthMate. 
Provide supportive, informative, and empathetic responses to health-related queries.
Context: ${message}

Guidelines:
- Be clear and concise
- Provide helpful information
- Avoid giving definitive medical diagnoses
- Always recommend consulting a healthcare professional for serious concerns
''';

      final response = await http
          .post(
            Uri.parse(baseUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'model': 'meditron',
              'prompt': prompt,
              'stream': false,
              'temperature': 0.7
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return responseData['response'] ??
            'I apologize, but I could not generate a response.';
      } else {
        throw Exception('Failed to generate response: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    } catch (e) {
      throw Exception('Error communicating with Ollama: $e');
    }
  }
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  final OllamaService _ollamaService = OllamaService();
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage(String message) {
    final trimmed = message.trim();
    if (trimmed.isEmpty) return;

    setState(() {
      _messages.insert(
          0,
          ChatMessage(
            role: MessageRole.user,
            message: trimmed,
            timestamp: DateTime.now(),
          ));
      _isLoading = true;
    });

    _getAIResponse(trimmed);
    _controller.clear();
    _scrollToBottom();
  }

  void _getAIResponse(String message) async {
    try {
      final response = await _ollamaService.generateResponse(message);

      setState(() {
        _messages.insert(
            0,
            ChatMessage(
              role: MessageRole.ai,
              message: response,
              timestamp: DateTime.now(),
            ));
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.insert(
            0,
            ChatMessage(
              role: MessageRole.ai,
              message:
                  'Sorry, I encountered an error: ${e.toString().replaceAll('Exception: ', '')}',
              timestamp: DateTime.now(),
            ));
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  Widget _buildMessageBubble(ChatMessage message) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HealthMate AI'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          if (_isLoading) const LinearProgressIndicator(),
          Padding(
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
                      suffixIcon: _isLoading
                          ? const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : null,
                    ),
                    enabled: !_isLoading,
                    onSubmitted: (value) {
                      if (!_isLoading && _controller.text.isNotEmpty) {
                        _sendMessage(_controller.text);
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  color: Theme.of(context).primaryColor,
                  onPressed: _isLoading
                      ? null
                      : () {
                          if (_controller.text.isNotEmpty) {
                            _sendMessage(_controller.text);
                          }
                        },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
