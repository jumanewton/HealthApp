// lib/models/health_record.dart

import 'package:cloud_firestore/cloud_firestore.dart';

enum RecordType {
  medicalDocument,
  labReport,
  imagingReport,
  prescription,
  medicalNotes,
  vaccination,
  other, labResult, appointment, imaging
}

class HealthRecord {
  final String id;
  final String title;
  final RecordType type;
  final String url;
  final DateTime dateAdded;
  final String? summary; // Field for AI-generated summary
  
  HealthRecord({
    required this.id,
    required this.title,
    required this.type,
    required this.url,
    required this.dateAdded,
    this.summary,
  });
  
  // Convert RecordType enum to string
  static String recordTypeToString(RecordType type) {
    return type.toString().split('.').last;
  }
  
  // Convert string to RecordType enum
  static RecordType stringToRecordType(String typeStr) {
    return RecordType.values.firstWhere(
      (e) => recordTypeToString(e) == typeStr,
      orElse: () => RecordType.other,
    );
  }
  
  // Factory method to create HealthRecord from document snapshot
  factory HealthRecord.fromMap(String id, Map<String, dynamic> data) {
    RecordType type;
    
    try {
      // Handle different formats of type data
      if (data['type'] is String) {
        if (data['type'].contains('.')) {
          // Handle full enum string format (e.g., "RecordType.labReport")
          type = RecordType.values.firstWhere(
            (e) => e.toString() == data['type'],
            orElse: () => RecordType.other,
          );
        } else {
          // Handle just the enum value (e.g., "labReport")
          type = RecordType.values.firstWhere(
            (e) => e.toString().split('.').last == data['type'],
            orElse: () => RecordType.other,
          );
        }
      } else {
        type = RecordType.other;
      }
    } catch (e) {
      type = RecordType.other;
    }
    
    // Handle date added
    DateTime dateAdded;
    try {
      if (data['dateAdded'] is Timestamp) {
        dateAdded = (data['dateAdded'] as Timestamp).toDate();
      } else if (data['dateAdded'] != null) {
        dateAdded = DateTime.parse(data['dateAdded'].toString());
      } else {
        dateAdded = DateTime.now();
      }
    } catch (e) {
      dateAdded = DateTime.now();
    }
    
    return HealthRecord(
      id: id,
      title: data['title'] ?? '',
      type: type,
      url: data['url'] ?? '',
      dateAdded: dateAdded,
      summary: data['summary'],
    );
  }
  
  // Convert to Map for database operations
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'type': recordTypeToString(type),
      'url': url,
      'dateAdded': dateAdded,
      'summary': summary,
    };
  }
  
  // Create a copy with modified fields
  HealthRecord copyWith({
    String? id,
    String? title,
    RecordType? type,
    String? url,
    DateTime? dateAdded,
    String? summary,
  }) {
    return HealthRecord(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      url: url ?? this.url,
      dateAdded: dateAdded ?? this.dateAdded,
      summary: summary ?? this.summary,
    );
  }
  
  @override
  String toString() {
    return 'HealthRecord(id: $id, title: $title, type: ${recordTypeToString(type)}, url: $url, dateAdded: $dateAdded)';
  }
}