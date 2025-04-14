import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  medication,
  appointment,
  healthTip,
  general,
}

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime timestamp;
  final String? payload;
  bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.timestamp,
    this.payload,
    this.isRead = false,
  });

  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    DateTime? timestamp,
    String? payload,
    bool? isRead,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      payload: payload ?? this.payload,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type.index,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'payload': payload,
      'isRead': isRead ? 1 : 0,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'],
      title: map['title'],
      body: map['body'],
      type: NotificationType.values[map['type']],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      payload: map['payload'],
      isRead: map['isRead'] == 1,
    );
  }
  factory NotificationModel.fromFirestore(
    Map<String, dynamic> data, 
    String id
  ) {
    return NotificationModel(
      id: id,
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == data['type'],
        orElse: () => NotificationType.general,
      ),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      payload: data['payload'],
      isRead: data['isRead'] ?? false,
    );
  }

  static NotificationType getTypeFromCalendarEvent(String category) {
    switch (category) {
      case 'medication':
        return NotificationType.medication;
      case 'appointment':
        return NotificationType.appointment;
      default:
        return NotificationType.general;
    }
  }
}