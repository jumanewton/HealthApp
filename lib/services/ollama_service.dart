import 'dart:convert';
import 'package:http/http.dart' as http;

class OllamaService {
  final String _baseUrl = 'http://localhost:11434/api/generate';

  Future<String> generateText(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'model': 'meditron',
          'prompt': prompt,
          'stream': false
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return responseData['response'] ?? 'No response';
      } else {
        throw Exception('Failed to generate text: ${response.body}');
      }
    } catch (e) {
      print('Error communicating with Ollama: $e');
      return 'An error occurred';
    }
  }
}