// lib/models/medication.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Medication {
  final String? id;
  final String name;
  final String dosage;
  final String schedule;
  final TimeOfDay reminderTime;
  final DateTime? dateAdded;

  Medication({
    this.id,
    required this.name,
    required this.dosage,
    required this.schedule,
    required this.reminderTime,
    this.dateAdded,
  });

  // Convert Firestore document to Medication object
  factory Medication.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Handle different data formats for reminderTime
    TimeOfDay reminderTime;
    if (data['reminderTime'] is Map) {
      final timeMap = data['reminderTime'] as Map<String, dynamic>;
      reminderTime = TimeOfDay(
        hour: timeMap['hour'],
        minute: timeMap['minute'],
      );
    } else if (data['reminderTime'] is String) {
      // Parse from string format if stored that way
      final parts = data['reminderTime'].toString().split(':');
      if (parts.length == 2) {
        reminderTime = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1].split(' ')[0]),
        );
      } else {
        // Default if parsing fails
        reminderTime = const TimeOfDay(hour: 8, minute: 0);
      }
    } else {
      // Default if no reminderTime
      reminderTime = const TimeOfDay(hour: 8, minute: 0);
    }

    return Medication(
      id: doc.id,
      name: data['name'] ?? 'Unknown',
      dosage: data['dosage'] ?? '',
      schedule: data['schedule'] ?? '',
      reminderTime: reminderTime,
      dateAdded: data['dateAdded'] != null
          ? (data['dateAdded'] as Timestamp).toDate()
          : null,
    );
  }

  // Convert Medication object to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'dosage': dosage,
      'schedule': schedule,
      'reminderTime': {
        'hour': reminderTime.hour,
        'minute': reminderTime.minute,
      },
      'dateAdded': dateAdded != null ? Timestamp.fromDate(dateAdded!) : null,
    };
  }
}
