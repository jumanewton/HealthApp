// lib/providers/notification_provider.dart
import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import '../services/notification_repository.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationRepository _repository = NotificationRepository();
  
  Stream<List<NotificationModel>> get notifications => _repository.getNotifications();
  
  Future<void> markAsRead(String notificationId) {
    return _repository.markAsRead(notificationId);
  }
  
  Future<void> markAllAsRead() {
    return _repository.markAllAsRead();
  }
  
  Future<void> deleteNotification(String notificationId) {
    return _repository.deleteNotification(notificationId);
  }
  
  Future<void> createMedicationReminder(
      String medicationId, String medicationName, String dosage, String schedule) {
    return _repository.createMedicationReminder(
        medicationId, medicationName, dosage, schedule);
  }
  
  Future<void> createHealthInsight(String title, String message, {Map<String, dynamic>? data}) {
    return _repository.createHealthInsight(title, message, data: data);
  }
}