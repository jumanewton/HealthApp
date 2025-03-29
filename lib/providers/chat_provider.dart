import 'package:flutter/foundation.dart';
import '../models/chat_message.dart';
import '../services/groq_service.dart';

class ChatProvider with ChangeNotifier {
  final GroqService _groqService;
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  ChatProvider({required GroqService groqService}) : _groqService = groqService;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;

  Future<void> sendMessage(String message) async {
    _messages.insert(
      0,
      ChatMessage(
        role: MessageRole.user,
        message: message,
        timestamp: DateTime.now(),
      ),
    );

    _isLoading = true;
    notifyListeners();

    try {
      final aiResponse = await _groqService.generateResponse(message);
      _messages.insert(
        0,
        ChatMessage(
          role: MessageRole.ai,
          message: aiResponse,
          timestamp: DateTime.now(),
        ),
      );
    } catch (e) {
      _messages.insert(
        0,
        ChatMessage(
          role: MessageRole.ai,
          message: 'Error: $e',
          timestamp: DateTime.now(),
        ),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void stopGeneration() {
    if (_isLoading) {
      _groqService.cancelRequest(); // Cancel API request
      _isLoading = false;
      notifyListeners();
    }
  }
}
