import 'dart:async';
import 'dart:convert';
import 'package:healthmate/utility/api_constants.dart';
import 'package:http/http.dart' as http;

class GroqService {
  final String apiKey;
  final String baseUrl;
  final http.Client? client;

  GroqService({
    required this.apiKey,
    String? baseUrl,
    this.client, // Allow dependency injection for testing
  }) : baseUrl = baseUrl ?? ApiConstants.groqBaseUrl;

  Stream<String> generateMedicalAdvice(String symptoms) async* {
    if (symptoms.trim().isEmpty) {
      throw ArgumentError('Symptoms description cannot be empty');
    }

    final prompt = _createPrompt(symptoms);
    final request = _buildRequest(prompt);
    final client = this.client ?? http.Client();
    final streamedResponse = await client.send(request);

    if (streamedResponse.statusCode != 200) {
      client.close();
      throw _handleApiError(streamedResponse);
    }

    yield* _processResponseStream(client, streamedResponse);
  }

  http.Request _buildRequest(String prompt) {
    return http.Request('POST', Uri.parse(baseUrl))
      ..headers.addAll({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      })
      ..body = jsonEncode({
        'model': ApiConstants.groqModel,
        'messages': [
          {
            'role': 'system',
            'content': _createSystemPrompt(),
          },
          {
            'role': 'user',
            'content': prompt,
          }
        ],
        'max_tokens': ApiConstants.maxTokens,
        'temperature': ApiConstants.temperature,
        'stream': true,
      });
  }

  Stream<String> _processResponseStream(
    http.Client client,
    http.StreamedResponse response,
  ) async* {
    try {
      await for (var chunk in response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())) {
        if (chunk.startsWith('data: ') && chunk.length > 6) {
          final content = _parseChunkContent(chunk.substring(6));
          if (content != null) yield content;
        }
      }
    } finally {
      client.close();
    }
  }

  String? _parseChunkContent(String jsonChunk) {
    try {
      final parsed = jsonDecode(jsonChunk);
      return parsed['choices']?[0]['delta']?['content']?.toString();
    } catch (e) {
      return null; // Skip malformed chunks
    }
  }

  Exception _handleApiError(http.StreamedResponse response) {
    final statusCode = response.statusCode;
    if (statusCode == 401) {
      return Exception('Invalid API key - please check your configuration');
    } else if (statusCode == 429) {
      return Exception('API rate limit exceeded - please wait before trying again');
    } else if (statusCode >= 500) {
      return Exception('Server error - please try again later');
    }
    return Exception('API request failed with status $statusCode');
  }

  String _createSystemPrompt() {
    return '''
You are a medical assistant providing preliminary, non-diagnostic advice. Follow these strict guidelines:

1. SAFETY FIRST:
   - Never provide definitive diagnoses
   - Always recommend professional consultation
   - Highlight urgent symptoms prominently

2. RESPONSE STRUCTURE:
   - Possible conditions (max 3, with likelihood indicators)
   - Recommended actions (prioritized by urgency)
   - Red flags (clearly marked with ⚠️)
   - When to seek help (specific timelines)

3. COMMUNICATION:
   - Use simple, non-alarming language
   - Include disclaimers in every section
   - Format in clear markdown with headings
   - Use emojis sparingly for emphasis

4. LIMITATIONS:
   - State this is informational only
   - Note you can't access patient history
   - Remind to consult a healthcare provider
''';
  }

  String _createPrompt(String symptoms) {
    return '''
Analyze these symptoms for a preliminary assessment:

**Patient-reported symptoms:**
$symptoms

Provide structured guidance including:
1. Potential explanations (most likely first)
2. Self-care measures (if appropriate)
3. Warning signs requiring immediate attention
4. Recommended timeline for professional consultation

Format clearly with these headings:
## Possible Conditions
## Recommended Actions
## Warning Signs
## When to Seek Help

Include this disclaimer prominently:
"⚠️ This is not medical advice. Always consult a qualified healthcare provider for proper diagnosis and treatment."
''';
  }
}