import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class OllamaService {
  final String baseUrl;

  OllamaService({this.baseUrl = 'http://127.0.0.1:11434/api/generate'});

  Future<String> generateMedicalAdvice(String symptoms) async {
    try {
      final prompt = '''
You are a medical assistant providing preliminary advice based on symptoms.
Patient reported symptoms: $symptoms

Please provide a structured response with:
1. Possible conditions (list 2-3 most likely, with brief explanations)
2. Recommended immediate actions (bullet points)
3. Red flags that indicate urgent care is needed
4. General advice on when to seek professional medical help

Format your response in clear markdown with appropriate headings.
Important: Emphasize prominently that this is not a definitive diagnosis and professional medical consultation is always recommended.
''';

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'model': 'meditron',
          'prompt': prompt,
          'stream': false,
          'temperature': 0.7
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return responseData['response'] ?? 'Unable to generate medical advice.';
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    } catch (e) {
      throw Exception('Error: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }
}

class SymptomCheckerPage extends StatefulWidget {
  const SymptomCheckerPage({super.key});

  @override
  State<SymptomCheckerPage> createState() => _SymptomCheckerPageState();
}

class _SymptomCheckerPageState extends State<SymptomCheckerPage> {
  final TextEditingController _symptomController = TextEditingController();
  final OllamaService _ollamaService = OllamaService();
  String _symptomResult = '';
  bool _isLoading = false;
  bool _hasSubmitted = false;

  @override
  void dispose() {
    _symptomController.dispose();
    super.dispose();
  }

  void _checkSymptoms() async {
    final symptom = _symptomController.text.trim();
    if (symptom.isEmpty) {
      setState(() {
        _symptomResult = 'Please enter your symptoms to continue.';
        _hasSubmitted = true;
      });
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _isLoading = true;
      _symptomResult = '';
      _hasSubmitted = true;
    });

    try {
      final advice = await _ollamaService.generateMedicalAdvice(symptom);
      setState(() {
        _symptomResult = advice;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _symptomResult = '⚠️ ${e.toString().replaceAll('Exception: ', '')}';
        _isLoading = false;
      });
    }
  }

  Widget _buildDisclaimer() {
    return Card(
      color: Colors.orange[50],
      margin: const EdgeInsets.only(bottom: 20),
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'Important Disclaimer',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'This AI symptom checker provides preliminary information only and is not a substitute for professional medical advice, diagnosis, or treatment. Always seek the advice of your physician or other qualified health provider with any questions you may have regarding a medical condition.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Symptom Checker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('About This Tool'),
                  content: const Text(
                    'This AI-powered symptom checker helps you understand possible causes for your symptoms and when to seek medical attention. It uses the Meditron medical AI model for analysis.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildDisclaimer(),
            Text(
              'Describe your symptoms:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _symptomController,
              decoration: InputDecoration(
                labelText: 'Symptoms',
                border: const OutlineInputBorder(),
                hintText: 'e.g., headache, fever, nausea',
                suffixIcon: _symptomController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _symptomController.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
              maxLines: 4,
              minLines: 1,
              maxLength: 500,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _checkSymptoms,
              icon: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.medical_services),
              label: Text(_isLoading ? 'Analyzing...' : 'Check Symptoms'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            if (_isLoading) const LinearProgressIndicator(),
            if (_hasSubmitted && _symptomResult.isEmpty && !_isLoading)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Analyzing your symptoms...'),
                ),
              ),
            if (_symptomResult.isNotEmpty)
              Card(
                margin: const EdgeInsets.only(top: 20),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Preliminary Analysis',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(height: 20),
                      MarkdownBody(
                        data: _symptomResult,
                        styleSheet: MarkdownStyleSheet(
                          p: const TextStyle(fontSize: 16),
                          h2: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                          h3: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.medical_services),
                        label: const Text('Find Nearby Clinics'),
                        onPressed: () {
                          // Could integrate with maps API here
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('This would open a clinic locator'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}