import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class GroqService {
  http.Client? _client;
  bool _isCancelled = false;
  final String _apiKey = dotenv.env['GROQ_API_KEY'] ?? ''; // Load API Key

  GroqService({required String apiKey}) {
    _client = http.Client();
  }

  Future<String> generateResponse(String message) async {
    _isCancelled = false; // Reset cancel state before starting a new request

    if (_apiKey.isEmpty) {
      debugPrint('Error: API Key is missing');
      return 'API Key is not set. Please check your configuration.';
    }

    try {
      final request = http.Request(
        'POST',
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
      );

      request.headers.addAll({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey', // Use API Key from .env
      });

      request.body = jsonEncode({
        'model': 'llama3-70b-8192', // Best available for healthcare
        'messages': [
          {
            'role': 'system',
            'content': '''
            You are HealthMate, a professional healthcare assistant.
            Guidelines:
            - Provide accurate, evidence-based information
            - Use simple language for medical concepts
            - Always include: "This is not medical advice - consult a doctor for..."
            - For emergencies, say: "Please seek immediate medical attention"
            - Be empathetic and supportive
            '''
          },
          {
            'role': 'user',
            'content': message
          }
        ],
        'temperature': 0.5,
        'max_tokens': 1024
      });

      final streamedResponse = await _client!.send(request);

      if (_isCancelled) {
        debugPrint('Request was cancelled.');
        return 'Request cancelled.';
      }

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['choices'][0]['message']['content'].trim();
      } else {
        debugPrint('API Error: ${response.body}');
        return 'Sorry, there was an error processing your request.';
      }
    } catch (e) {
      if (_isCancelled) {
        return 'Request cancelled.';
      }
      debugPrint('Exception in API call: $e');
      return 'An unexpected error occurred.';
    }
  }

  void cancelRequest() {
    _isCancelled = true;
    _client?.close(); // Closes the client, cancelling all ongoing requests
    _client = http.Client(); // Reinitialize client for future requests
  }
}
