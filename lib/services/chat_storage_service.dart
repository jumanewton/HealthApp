import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/conversation.dart';

class ChatStorageService {
  static const String _conversationsKey = 'stored_conversations';
  
  // Save a conversation to local storage
  Future<bool> saveConversation(Conversation conversation) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> storedConversations = prefs.getStringList(_conversationsKey) ?? [];
      
      // Convert the conversation to a JSON string
      final conversationJson = jsonEncode(conversation.toJson());
      
      // Check if this conversation already exists
      int existingIndex = -1;
      for (int i = 0; i < storedConversations.length; i++) {
        final stored = jsonDecode(storedConversations[i]);
        if (stored['id'] == conversation.id) {
          existingIndex = i;
          break;
        }
      }
      
      // Update or add the conversation
      if (existingIndex >= 0) {
        storedConversations[existingIndex] = conversationJson;
      } else {
        storedConversations.add(conversationJson);
      }
      
      // Save the updated list
      await prefs.setStringList(_conversationsKey, storedConversations);
      return true;
    } catch (e) {
      print('Error saving conversation: $e');
      return false;
    }
  }
  
  // Retrieve all saved conversations
  Future<List<Conversation>> getConversations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> storedConversations = prefs.getStringList(_conversationsKey) ?? [];
      
      return storedConversations.map((jsonStr) {
        final Map<String, dynamic> json = jsonDecode(jsonStr);
        return Conversation.fromJson(json);
      }).toList();
    } catch (e) {
      print('Error retrieving conversations: $e');
      return [];
    }
  }
  
  // Delete a conversation by ID
  Future<bool> deleteConversation(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> storedConversations = prefs.getStringList(_conversationsKey) ?? [];
      
      List<String> updatedConversations = [];
      for (String jsonStr in storedConversations) {
        final Map<String, dynamic> json = jsonDecode(jsonStr);
        if (json['id'] != id) {
          updatedConversations.add(jsonStr);
        }
      }
      
      await prefs.setStringList(_conversationsKey, updatedConversations);
      return true;
    } catch (e) {
      print('Error deleting conversation: $e');
      return false;
    }
  }
  
  // Clear all conversations
  Future<bool> clearAllConversations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_conversationsKey);
      return true;
    } catch (e) {
      print('Error clearing conversations: $e');
      return false;
    }
  }
}