import 'package:flutter/material.dart';

class HealthInsightsPage extends StatelessWidget {
  const HealthInsightsPage({super.key});

  // Dummy data for health insights (replace with Firebase data)
  final Map<String, dynamic> healthData = const {
    'weight': '75 kg',
    'steps': '4,500 / 10,000',
    'heartRate': '72 BPM',
    'sleep': '6.5 hours',
  };

  final List<String> recommendations = const [
    'Drink at least 8 glasses of water today.',
    'Take a 30-minute walk to reach your step goal.',
    'Aim for 7-8 hours of sleep tonight.',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Insights'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Health Trends Section
            const Text(
              'Health Trends',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildHealthTrendItem('Weight', healthData['weight']),
                    _buildHealthTrendItem('Steps', healthData['steps']),
                    _buildHealthTrendItem('Heart Rate', healthData['heartRate']),
                    _buildHealthTrendItem('Sleep', healthData['sleep']),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Personalized Recommendations Section
            const Text(
              'Personalized Recommendations',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: recommendations
                      .map((recommendation) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              children: [
                                const Icon(Icons.thumb_up, color: Colors.green),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    recommendation,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Actionable Tips Section
            const Text(
              'Actionable Tips',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      '1. Stay hydrated throughout the day.',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '2. Take short breaks to stretch if you sit for long periods.',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '3. Avoid sugary snacks and opt for fruits or nuts.',
                      style: TextStyle(fontSize: 16),
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

  Widget _buildHealthTrendItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}