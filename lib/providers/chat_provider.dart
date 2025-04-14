import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/chat_message.dart';
import '../models/conversation.dart';
import '../services/groq_service.dart';
import '../services/chat_storage_service.dart';

class ChatProvider with ChangeNotifier {
  final GroqService _groqService;
  final ChatStorageService _storageService;
  
  Conversation? _currentConversation;
  List<Conversation> _conversations = [];
  bool _isLoading = false;
  StreamSubscription? _streamSubscription;
  
  ChatProvider({
    required GroqService groqService,
    required ChatStorageService storageService,
  }) : 
    _groqService = groqService,
    _storageService = storageService {
    _loadConversations();
  }

  // Getters
  List<ChatMessage> get messages => 
      _currentConversation?.messages ?? [];
      
  List<Conversation> get conversations => 
      List.unmodifiable(_conversations);
      
  Conversation? get currentConversation => _currentConversation;
  
  bool get isLoading => _isLoading;
  bool get hasCurrentConversation => _currentConversation != null;

  // Load all saved conversations
  Future<void> _loadConversations() async {
    _conversations = await _storageService.getConversations();
    // Sort by last updated, newest first
    _conversations.sort((a, b) => b.lastUpdatedAt.compareTo(a.lastUpdatedAt));
    notifyListeners();
  }

  // Start a new conversation
  void startNewConversation() {
    _currentConversation = Conversation(
      title: "New conversation",
      messages: [],
    );
    notifyListeners();
  }

  // Load a specific conversation
  void loadConversation(String conversationId) {
    _currentConversation = _conversations.firstWhere(
      (conv) => conv.id == conversationId,
    );
    notifyListeners();
  }

  // Send a message in the current conversation
  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;
    
    // Create a new conversation if none exists
    if (_currentConversation == null) {
      startNewConversation();
    }
    
    // Add user message
    final userMessage = ChatMessage(
      role: MessageRole.user,
      message: message,
      timestamp: DateTime.now(),
    );
    _currentConversation!.messages.insert(0, userMessage);
    
    // If this is the first message, generate a title
    if (_currentConversation!.messages.length == 1) {
      _currentConversation!.title = Conversation.generateTitle([userMessage]);
    }
    
    // Create AI message placeholder
    final aiMessage = ChatMessage(
      role: MessageRole.ai,
      message: '',
      timestamp: DateTime.now(),
      isLoading: true,
    );
    _currentConversation!.messages.insert(0, aiMessage);
    
    _isLoading = true;
    notifyListeners();

    try {
      // Start streaming response
      final responseStream = _groqService.streamResponse(message);
      
      // Listen to the stream and update the AI message
      _streamSubscription = responseStream.listen(
        (chunk) {
          aiMessage.message += chunk;
          aiMessage.isLoading = false;
          notifyListeners();
        },
        onDone: () {
          _isLoading = false;
          aiMessage.isLoading = false;
          _streamSubscription = null;
          
          // Update conversation metadata
          _currentConversation!.lastUpdatedAt = DateTime.now();
          
          // Save the conversation
          _saveCurrentConversation();
          
          notifyListeners();
        },
        onError: (error) {
          aiMessage.message = 'Error: $error';
          aiMessage.isLoading = false;
          _isLoading = false;
          _streamSubscription = null;
          
          // Update conversation metadata
          _currentConversation!.lastUpdatedAt = DateTime.now();
          
          // Save the conversation
          _saveCurrentConversation();
          
          notifyListeners();
        },
      );
    } catch (e) {
      aiMessage.message = 'Error: $e';
      aiMessage.isLoading = false;
      _isLoading = false;
      
      // Update conversation metadata
      _currentConversation!.lastUpdatedAt = DateTime.now();
      
      // Save the conversation
      _saveCurrentConversation();
      
      notifyListeners();
    }
  }

  // Stop the current generation
  void stopGeneration() {
    if (_isLoading) {
      _streamSubscription?.cancel();
      _streamSubscription = null;
      _groqService.cancelRequest();
      
      // Mark the loading message as no longer loading
      for (final message in _currentConversation!.messages) {
        if (message.isLoading) {
          message.isLoading = false;
          if (message.message.isEmpty) {
            message.message = '[Generation stopped]';
          }
        }
      }
      
      _isLoading = false;
      
      // Update conversation metadata
      _currentConversation!.lastUpdatedAt = DateTime.now();
      
      // Save the conversation
      _saveCurrentConversation();
      
      notifyListeners();
    }
  }
  
  // Save the current conversation
  Future<void> _saveCurrentConversation() async {
    if (_currentConversation != null) {
      await _storageService.saveConversation(_currentConversation!);
      
      // Refresh the conversations list
      await _loadConversations();
    }
  }
  
  // Delete a conversation
  Future<void> deleteConversation(String id) async {
    await _storageService.deleteConversation(id);
    
    // If we deleted the current conversation, clear it
    if (_currentConversation?.id == id) {
      _currentConversation = null;
    }
    
    // Refresh the conversations list
    await _loadConversations();
  }
  
  // Clear all conversations
  Future<void> clearAllConversations() async {
    await _storageService.clearAllConversations();
    _currentConversation = null;
    _conversations = [];
    notifyListeners();
  }
  
  // Update conversation title
  Future<void> updateConversationTitle(String id, String newTitle) async {
    // Find and update the conversation
    for (final conversation in _conversations) {
      if (conversation.id == id) {
        conversation.title = newTitle;
        await _storageService.saveConversation(conversation);
        
        // Update current conversation if it's the same one
        if (_currentConversation?.id == id) {
          _currentConversation!.title = newTitle;
        }
        
        break;
      }
    }
    
    notifyListeners();
  }
  
  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }
}