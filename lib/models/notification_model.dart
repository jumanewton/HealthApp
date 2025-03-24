// lib/models/notification_model.dart
class NotificationModel {
  final String id;
  final String type;
  final String title;
  final String description;
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic>? additionalData;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.timestamp,
    this.isRead = false,
    this.additionalData,
  });

  String get timeAgo {
    final difference = DateTime.now().difference(timestamp);
    
    if (difference.inDays > 7) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'description': description,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isRead': isRead,
      'additionalData': additionalData,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map, String docId) {
    return NotificationModel(
      id: docId,
      type: map['type'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
      isRead: map['isRead'] ?? false,
      additionalData: map['additionalData'],
    );
  }

  NotificationModel copyWith({
    String? id,
    String? type,
    String? title,
    String? description,
    DateTime? timestamp,
    bool? isRead,
    Map<String, dynamic>? additionalData,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      additionalData: additionalData ?? this.additionalData,
    );
  }
}