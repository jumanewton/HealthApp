import 'package:cloud_firestore/cloud_firestore.dart';

class HealthRecord {
  final String id;
  final String title;
  final String date;
  final String type;
  final String url;

  HealthRecord({
    required this.id,
    required this.title,
    required this.date,
    required this.type,
    required this.url,
  });

  factory HealthRecord.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return HealthRecord(
      id: doc.id,
      title: data['title'] ?? 'Untitled',
      date: data['date'] ?? 'No date',
      type: data['type'] ?? 'Document',
      url: data['url'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'date': date,
      'type': type,
      'url': url,
    };
  }
}