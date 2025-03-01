import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HealthRecordsPage extends StatelessWidget {
  const HealthRecordsPage({super.key});

  // Dummy data for health records (replace with Firebase data)
  final List<Map<String, String>> healthRecords = const [
    {
      'title': 'Blood Test Report',
      'date': 'Jan 15, 2024',
      'type': 'Lab Report',
      'url': 'https://example.com/blood_test.pdf',
    },
    {
      'title': 'X-Ray Report',
      'date': 'Feb 1, 2024',
      'type': 'Imaging Report',
      'url': 'https://example.com/xray_report.pdf',
    },
    {
      'title': 'Doctor Consultation Notes',
      'date': 'Mar 10, 2024',
      'type': 'Medical Notes',
      'url': 'https://example.com/consultation_notes.pdf',
    },
  ];

  // Function to open a health record URL
  Future<void> _openHealthRecord(String url) async {
    final Uri recordUri = Uri.parse(url);
    if (await canLaunch(recordUri.toString())) {
      await launch(recordUri.toString());
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Records'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: healthRecords.length,
        itemBuilder: (context, index) {
          final record = healthRecords[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            child: ListTile(
              leading: const Icon(Icons.medical_services, size: 40),
              title: Text(record['title']!),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(record['type']!),
                  const SizedBox(height: 4),
                  Text(
                    record['date']!,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.download),
                onPressed: () => _openHealthRecord(record['url']!),
              ),
              onTap: () => _openHealthRecord(record['url']!),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to Upload Health Record Page
        },
        child: const Icon(Icons.upload),
      ),
    );
  }
}