// Models folder - lib/models/calendar_event.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

enum EventCategory {
  medication,
  appointment,
  reminder,
}

extension EventCategoryExtension on EventCategory {
  String get name {
    switch (this) {
      case EventCategory.medication:
        return 'Medication';
      case EventCategory.appointment:
        return 'Appointment';
      case EventCategory.reminder:
        return 'Reminder';
    }
  }

  String get icon {
    switch (this) {
      case EventCategory.medication:
        return 'pill';
      case EventCategory.appointment:
        return 'calendar';
      case EventCategory.reminder:
        return 'alarm';
    }
  }

  int get color {
    switch (this) {
      case EventCategory.medication:
        return 0xFF4CAF50; // Green
      case EventCategory.appointment:
        return 0xFF2196F3; // Blue
      case EventCategory.reminder:
        return 0xFFFFC107; // Amber
    }
  }
}

enum RecurrencePattern {
  once,
  daily,
  weekly,
  monthly,
}

extension RecurrencePatternExtension on RecurrencePattern {
  String get name {
    switch (this) {
      case RecurrencePattern.once:
        return 'Once';
      case RecurrencePattern.daily:
        return 'Daily';
      case RecurrencePattern.weekly:
        return 'Weekly';
      case RecurrencePattern.monthly:
        return 'Monthly';
    }
  }
}

class CalendarEvent {
  final String id;
  final String title;
  final String description;
  final DateTime dateTime;
  final EventCategory category;
  final RecurrencePattern recurrence;
  final int notificationId;
  final bool isCompleted;

  CalendarEvent({
    String? id,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.category,
    this.recurrence = RecurrencePattern.once,
    int? notificationId,
    this.isCompleted = false,
  }) : id = id ?? const Uuid().v4(),
       notificationId = notificationId ?? DateTime.now().millisecondsSinceEpoch.hashCode;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dateTime': dateTime,
      'category': category.index,
      'recurrence': recurrence.index,
      'notificationId': notificationId,
      'isCompleted': isCompleted,
    };
  }

  factory CalendarEvent.fromMap(Map<String, dynamic> map) {
    return CalendarEvent(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      dateTime: (map['dateTime'] as Timestamp).toDate(),
      category: EventCategory.values[map['category']],
      recurrence: RecurrencePattern.values[map['recurrence']],
      notificationId: map['notificationId'],
      isCompleted: map['isCompleted'] ?? false,
    );
  }

  CalendarEvent copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dateTime,
    EventCategory? category,
    RecurrencePattern? recurrence,
    int? notificationId,
    bool? isCompleted,
  }) {
    return CalendarEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      category: category ?? this.category,
      recurrence: recurrence ?? this.recurrence,
      notificationId: notificationId ?? this.notificationId,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  // Calculate next occurrence based on recurrence pattern
  DateTime getNextOccurrence() {
    switch (recurrence) {
      case RecurrencePattern.once:
        return dateTime;
      case RecurrencePattern.daily:
        return dateTime.add(const Duration(days: 1));
      case RecurrencePattern.weekly:
        return dateTime.add(const Duration(days: 7));
      case RecurrencePattern.monthly:
        // Simple approach - may need more sophisticated logic for real-world scenarios
        final nextMonth = dateTime.month < 12 
            ? DateTime(dateTime.year, dateTime.month + 1, dateTime.day)
            : DateTime(dateTime.year + 1, 1, dateTime.day);
        return DateTime(
          nextMonth.year, 
          nextMonth.month, 
          nextMonth.day,
          dateTime.hour,
          dateTime.minute,
        );
    }
  }
}

// Medication-specific event
class MedicationEvent extends CalendarEvent {
  final String dosage;
  final String medicationId;

  MedicationEvent({
    required String title,
    required this.dosage,
    required DateTime dateTime,
    required String description,
    required this.medicationId,
    required RecurrencePattern recurrence,
    String? id,
    int? notificationId,
    bool isCompleted = false,
  }) : super(
          id: id,
          title: title,
          description: description,
          dateTime: dateTime,
          category: EventCategory.medication,
          recurrence: recurrence,
          notificationId: notificationId,
          isCompleted: isCompleted,
        );

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map.addAll({
      'dosage': dosage,
      'medicationId': medicationId,
    });
    return map;
  }

  factory MedicationEvent.fromMap(Map<String, dynamic> map) {
    return MedicationEvent(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      dateTime: (map['dateTime'] as Timestamp).toDate(),
      dosage: map['dosage'],
      medicationId: map['medicationId'],
      recurrence: RecurrencePattern.values[map['recurrence']],
      notificationId: map['notificationId'],
      isCompleted: map['isCompleted'] ?? false,
    );
  }
}