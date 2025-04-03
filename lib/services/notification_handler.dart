import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../services/notification_service.dart';
import '../providers/notification_provider.dart';
import '../models/notification_model.dart';
import '../models/calendar_event.dart';
import 'package:uuid/uuid.dart';

class NotificationHandler {
  static final NotificationHandler _instance = NotificationHandler._internal();
  factory NotificationHandler() => _instance;
  NotificationHandler._internal();

  final _uuid = Uuid();
  late NotificationProvider _notificationProvider;
  
  // Must be called after app startup
  void initialize(NotificationProvider provider) {
    _notificationProvider = provider;
    _setupNotificationListeners();
  }

  void _setupNotificationListeners() {
    final service = NotificationService();

    // Configure the notification service to call our handler
    service.configureSelectNotificationHandler(
      (NotificationResponse response) {
        _onNotificationSelected(response.payload);
      },
    );
  }

  // When a notification is received
  Future<void> onNotificationReceived({
    required String title,
    required String body,
    required NotificationType type,
    String? payload,
  }) async {
    await _notificationProvider.createNotification(
      title: title,
      body: body,
      type: type,
      payload: payload,
    );
  }

  // When a user taps on a notification
  void _onNotificationSelected(String? payload) {
    _notificationProvider.onNotificationReceived(payload);
    // Additional navigation could be handled here or in the provider
  }

  // Schedule a medication reminder notification with storage in our system
  Future<void> scheduleMedicationReminder({
    required String medicationName,
    required String dosage,
    required TimeOfDay time,
    required bool daily,
  }) async {
    // Generate a unique ID for this notification
    final int notificationId = _generateUniqueId();
    final String notificationPayload = 'medication_${_uuid.v4()}';
    
    // Schedule the system notification
    await NotificationService().scheduleTimeNotification(
      id: notificationId,
      title: 'Medication Reminder',
      body: 'Time to take $medicationName ($dosage)',
      time: time,
      payload: notificationPayload,
      daily: daily,
    );
    
    // Also store in our notification system
    await _notificationProvider.createNotification(
      title: 'Medication Reminder',
      body: 'Time to take $medicationName ($dosage)',
      type: NotificationType.medication,
      payload: notificationPayload,
    );
  }

  // Schedule an event notification with storage
  Future<void> scheduleEventNotification(CalendarEvent event) async {
    // First schedule the system notification
    await NotificationService().scheduleEventNotification(event);
    
    // Also store in our notification system
    final type = _getNotificationTypeFromEvent(event);
    
    await _notificationProvider.createNotification(
      title: event.title,
      body: event.description,
      type: type,
      payload: event.id,
    );
  }

  // Generate a unique notification ID
  int _generateUniqueId() {
    return DateTime.now().millisecondsSinceEpoch.remainder(100000);
  }

  // Convert EventCategory to NotificationType
  NotificationType _getNotificationTypeFromEvent(CalendarEvent event) {
    switch (event.category) {
      case EventCategory.medication:
        return NotificationType.medication;
      case EventCategory.appointment:
        return NotificationType.appointment;
      default:
        return NotificationType.general;
    }
  }
}