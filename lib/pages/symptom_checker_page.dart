import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../services/groq_service1.dart';
import '../widgets/disclaimer_card.dart';

class SymptomCheckerPage extends StatefulWidget {
  const SymptomCheckerPage({super.key});

  @override
  State<SymptomCheckerPage> createState() => _SymptomCheckerPageState();
}

class _SymptomCheckerPageState extends State<SymptomCheckerPage> {
  final TextEditingController _symptomController = TextEditingController();
  GroqService? _groqService;
  String _symptomResult = '';
  bool _isLoading = false;
  bool _hasSubmitted = false;
  StreamSubscription<String>? _responseSubscription;
  DateTime? _lastUpdate;

  static const _kThrottleDuration = Duration(milliseconds: 200);

  @override
  void initState() {
    super.initState();
    _initializeGroqService();
  }

  void _initializeGroqService() {
    final apiKey = dotenv.env['GROQ_API_KEY'];
    
    if (apiKey == null || apiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Groq API Key is missing. Please configure your .env file.'),
          backgroundColor: Colors.red,
        )
      );
      return;
    }
    
    setState(() {
      _groqService = GroqService(apiKey: apiKey);
    });
  }

  @override
  void dispose() {
    _symptomController.dispose();
    _responseSubscription?.cancel();
    super.dispose();
  }

  void _checkSymptoms() {
    if (_groqService == null) {
      _initializeGroqService();
      return;
    }

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
      _lastUpdate = null;
    });

    _responseSubscription?.cancel();

    _responseSubscription = _groqService!.generateMedicalAdvice(symptom).listen(
      (responseChunk) {
        final now = DateTime.now();
        if (_lastUpdate == null || now.difference(_lastUpdate!) > _kThrottleDuration) {
          setState(() {
            _symptomResult += responseChunk;
            _lastUpdate = now;
          });
        } else {
          _symptomResult += responseChunk;
        }
      },
      onError: (e) {
        setState(() {
          _symptomResult = '⚠️ ${e.toString().replaceAll('Exception: ', '')}';
          _isLoading = false;
        });
      },
      onDone: () {
        setState(() {
          _isLoading = false;
        });
      },
    );
  }

  void _stopGeneration() {
    _responseSubscription?.cancel();
    setState(() {
      _isLoading = false;
    });
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
                    'This AI-powered symptom checker helps you understand possible causes for your symptoms and when to seek medical attention. It uses the Llama3 medical AI model for analysis.',
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
            const DisclaimerCard(),
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
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading || _groqService == null ? null : _checkSymptoms,
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
                ),
                if (_isLoading)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: TextButton(
                      onPressed: _stopGeneration,
                      child: const Text('Stop'),
                    ),
                  ),
              ],
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