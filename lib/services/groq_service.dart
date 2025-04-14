import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class GroqService {
  final http.Client _client = http.Client();
  StreamController<String>? _streamController;
  final String _apiKey;
  
  GroqService({String? apiKey}) : _apiKey = apiKey ?? dotenv.env['GROQ_API_KEY'] ?? '';

  Stream<String> streamResponse(String message) {
    // Create a new stream controller for this request
    _streamController = StreamController<String>();
    
    if (_apiKey.isEmpty) {
      _streamController!.add('API Key is not set. Please check your configuration.');
      _streamController!.close();
      return _streamController!.stream;
    }

    _makeStreamingRequest(message);
    return _streamController!.stream;
  }

  Future<void> _makeStreamingRequest(String message) async {
    try {
      final request = http.Request(
        'POST',
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
      );

      request.headers.addAll({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      });

      request.body = jsonEncode({
        'model': 'llama3-70b-8192',
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
            - Keep responses brief and to the point, unless detail is explicitly requested.
            '''
          },
          {
            'role': 'user',
            'content': message
          }
        ],
        'temperature': 0.5,
        'max_tokens': 512,
        'stream': true  // Enable streaming responses
      });

      final streamedResponse = await _client.send(request);

      if (streamedResponse.statusCode != 200) {
        final response = await http.Response.fromStream(streamedResponse);
        debugPrint('API Error: ${response.body}');
        _streamController?.add('Sorry, there was an error processing your request.');
        _streamController?.close();
        return;
      }

      // Process the streaming response
      streamedResponse.stream.transform(utf8.decoder).listen(
        (String chunk) {
          if (chunk.trim().isNotEmpty) {
            // Format of each chunk is: data: {JSON}\n\n
            for (final line in chunk.split('\n\n')) {
              if (line.startsWith('data: ') && line != 'data: [DONE]') {
                try {
                  final jsonData = jsonDecode(line.substring(6));
                  final content = jsonData['choices'][0]['delta']['content'] ?? '';
                  if (content.isNotEmpty) {
                    _streamController?.add(content);
                  }
                } catch (e) {
                  debugPrint('Error parsing chunk: $e');
                }
              }
            }
          }
        },
        onDone: () {
          _streamController?.close();
        },
        onError: (error) {
          debugPrint('Stream error: $error');
          _streamController?.addError(error);
          _streamController?.close();
        },
        cancelOnError: true,
      );
    } catch (e) {
      debugPrint('Exception in API call: $e');
      _streamController?.add('An unexpected error occurred.');
      _streamController?.close();
    }
  }

  void cancelRequest() {
    _streamController?.close();
  }

  void dispose() {
    _client.close();
  }
}