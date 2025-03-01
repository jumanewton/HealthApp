import 'package:flutter/material.dart';

class SymptomCheckerPage extends StatefulWidget {
  const SymptomCheckerPage({super.key});

  @override
  State<SymptomCheckerPage> createState() => _SymptomCheckerPageState();
}

class _SymptomCheckerPageState extends State<SymptomCheckerPage> {
  final TextEditingController _symptomController = TextEditingController();
  String _symptomResult = '';

  void _checkSymptoms() {
    final symptom = _symptomController.text.trim();
    if (symptom.isEmpty) {
      setState(() {
        _symptomResult = 'Please enter your symptoms.';
      });
      return;
    }

    // Dummy logic for symptom checking (replace with AI/API integration)
    setState(() {
      _symptomResult = 'Based on your symptoms ($symptom), it is recommended to:\n\n'
          '- Drink plenty of water.\n'
          '- Rest and avoid strenuous activities.\n'
          '- Consult a doctor if symptoms persist.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Symptom Checker'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _symptomController,
              decoration: const InputDecoration(
                labelText: 'Enter your symptoms',
                border: OutlineInputBorder(),
                hintText: 'e.g., headache, fever, cough',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkSymptoms,
              child: const Text('Check Symptoms'),
            ),
            const SizedBox(height: 20),
            if (_symptomResult.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _symptomResult,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}