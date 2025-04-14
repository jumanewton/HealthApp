import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../repositories/notification_repository.dart';
import '../services/notification_service.dart';
import 'package:uuid/uuid.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationRepository _repository;
  final NotificationService _notificationService;
  final FirebaseFirestore _firestore;
  final Uuid _uuid;

  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  StreamSubscription? _notificationsSubscription;
  StreamSubscription? _medicationsSubscription;
  StreamSubscription? _eventsSubscription;
  String? _userId;

  NotificationProvider({
    required NotificationRepository repository,
    required NotificationService notificationService,
    FirebaseFirestore? firestore,
    Uuid? uuid,
  })  : _repository = repository,
          _notificationService = notificationService,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _uuid = uuid ?? Uuid();

  // Getters
  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;

  // Initialize provider
  Future<void> init({String? userId}) async {
    _isLoading = true;
    notifyListeners();

    try {
      _userId = userId;
      // 1. Initialize notification service
      await _notificationService.init();
      
      // 2. Configure notification handler
      await _notificationService.configureSelectNotificationHandler(
        (response) => onNotificationReceived(response.payload),
      );

      // 3. Load initial notifications
      await _loadNotifications();

      // 4. Set up listeners
      if (_userId != null) {
        _listenForNotifications(_userId!);
        _listenForFirestoreChanges(_userId!);
      }
    } catch (e) {
      debugPrint('Error initializing NotificationProvider: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load notifications from repository
  Future<void> _loadNotifications() async {
    try {
      _notifications = await _repository.getAllNotifications();
      _unreadCount = await _repository.getUnreadCount();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    }
  }

  // Listen for notification updates
  void _listenForNotifications(String userId) {
    // If you want to listen to Firestore notifications collection directly
    _notificationsSubscription?.cancel();
    _notificationsSubscription = _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
          final notificationsList = snapshot.docs
              .map((doc) => NotificationModel.fromFirestore(doc.data(), doc.id))
              .toList();
          
          _notifications = notificationsList;
          _unreadCount = notificationsList.where((n) => !n.isRead).length;
          notifyListeners();
        });
  }

  // Listen for Firestore changes that should trigger notifications
  void _listenForFirestoreChanges(String userId) {
    // Listen for medications
    _medicationsSubscription?.cancel();
    _medicationsSubscription = _firestore
        .collection('users')
        .doc(userId)
        .collection('medications')
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added ||
            change.type == DocumentChangeType.modified) {
          _handleMedicationChange(change.doc.data()!, change.doc.id);
        }
      }
    });

    // Listen for events
    _eventsSubscription?.cancel();
    _eventsSubscription = _firestore
        .collection('users')
        .doc(userId)
        .collection('events')
        .where('dateTime', isGreaterThan: Timestamp.fromDate(DateTime.now()))
        .where('isCompleted', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          _handleEventChange(change.doc);
        }
      }
    });
  }

  Future<void> _handleMedicationChange(Map<String, dynamic> medication, String docId) async {
    try {
      // Extract reminder time
      final reminderHour = medication['reminderTime']['hour'] ?? 9;
      final reminderMinute = medication['reminderTime']['minute'] ?? 0;
      
      // Schedule notification
      await _notificationService.scheduleTimeNotification(
        id: docId.hashCode,
        title: 'Medication Reminder',
        body: 'Time to take ${medication['name']} (${medication['dosage']})',
        time: TimeOfDay(
          hour: reminderHour,
          minute: reminderMinute,
        ),
        daily: true,
      );

      // Create in-app notification
      await createNotification(
        title: 'Medication Scheduled',
        body: 'Reminder set for ${medication['name']}',
        type: NotificationType.medication,
        payload: docId,
      );
    } catch (e) { 
      debugPrint('Error scheduling medication notification: $e');
    }
  }

  Future<void> _handleEventChange(DocumentSnapshot eventDoc) async {
    try {
      final eventData = eventDoc.data() as Map<String, dynamic>;
      final eventType = eventData['category'] as int? ?? 0;
      final eventTitle = eventData['title'] as String? ?? 'Event';
      final eventDescription = eventData['description'] as String? ?? '';
      final eventDateTime = (eventData['dateTime'] as Timestamp).toDate();
      
      // Map event category to notification type
      final notificationType = _mapEventCategoryToNotificationType(eventType);
      
      // Schedule notification
      await _notificationService.scheduleNotification(
        id: eventDoc.id.hashCode,
        title: eventTitle,
        body: eventDescription,
        scheduledDate: eventDateTime.subtract(const Duration(hours: 1)), // 1 hour before event
        payload: eventDoc.id,
      );
      
      // Create in-app notification
      await createNotification(
        title: eventTitle,
        body: eventDescription,
        type: notificationType,
        payload: eventDoc.id,
      );
      
      // Mark notification as sent
      await eventDoc.reference.update({'notificationSent': true});
    } catch (e) {
      debugPrint('Error scheduling event notification: $e');
    }
  }

  // Create a notification
  Future<void> createNotification({
    required String title,
    required String body,
    required NotificationType type,
    String? payload,
  }) async {
    final notification = NotificationModel(
      id: _uuid.v4(),
      title: title,
      body: body,
      type: type,
      timestamp: DateTime.now(),
      payload: payload,
      isRead: false,
    );

    await _repository.insertNotification(notification);
    // If you want to also store in Firestore
    if (_userId != null) {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('notifications')
          .doc(notification.id)
          .set({
        'title': notification.title,
        'body': notification.body,
        'type': notification.type.toString(),
        'timestamp': Timestamp.fromDate(notification.timestamp),
        'payload': notification.payload,
        'isRead': notification.isRead,
      });
    }
    await _loadNotifications();
  }

  NotificationType _mapEventCategoryToNotificationType(int category) {
    // Based on your event categories
    switch (category) {
      case 0:
        return NotificationType.general;
      case 1:
        return NotificationType.medication;
      case 2:
        return NotificationType.appointment;
      default:
        return NotificationType.general;
    }
  }

  // Handle notification tap
  Future<void> onNotificationReceived(String? payload) async {
    if (payload == null) return;

    try {
      // Mark as read
      await markAsRead(payload);

      // Find the notification
      final notification = _notifications.firstWhere(
        (n) => n.id == payload || n.payload == payload,
        orElse: () => NotificationModel(
          id: '',
          title: '',
          body: '',
          type: NotificationType.general,
          timestamp: DateTime.now(),
        ),
      );

      // Handle navigation or other actions based on notification type
      if (notification.id.isNotEmpty) {
        if (notification.type == NotificationType.medication) {
          debugPrint('Opening medication: ${notification.payload}');
          // Navigate to medication detail
        } else if (notification.type == NotificationType.appointment) {
          debugPrint('Opening appointment: ${notification.payload}');
          // Navigate to appointment detail
        }
      }
    } catch (e) {
      debugPrint('Error handling notification tap: $e');
    }
  }

  // Mark as read
  Future<void> markAsRead(String notificationId) async {
    await _repository.markAsRead(notificationId);
    
    // Also update in Firestore if using it
    if (_userId != null) {
      // Try to find by ID first
      final notification = _notifications.firstWhere(
        (n) => n.id == notificationId,
        orElse: () => NotificationModel(
          id: '',
          title: '',
          body: '',
          type: NotificationType.general,
          timestamp: DateTime.now(),
        ),
      );
      
      if (notification.id.isNotEmpty) {
        await _firestore
            .collection('users')
            .doc(_userId)
            .collection('notifications')
            .doc(notification.id)
            .update({'isRead': true});
      }
      
      // Also try by payload if needed
      final payloadNotification = _notifications.firstWhere(
        (n) => n.payload == notificationId,
        orElse: () => NotificationModel(
          id: '',
          title: '',
          body: '',
          type: NotificationType.general,
          timestamp: DateTime.now(),
        ),
      );
      
      if (payloadNotification.id.isNotEmpty) {
        await _firestore
            .collection('users')
            .doc(_userId)
            .collection('notifications')
            .doc(payloadNotification.id)
            .update({'isRead': true});
      }
    }
    
    await _loadNotifications();
  }

  // Mark all as read
  Future<void> markAllAsRead() async {
    await _repository.markAllAsRead();
    
    // Also update in Firestore if using it
    if (_userId != null) {
      final batch = _firestore.batch();
      
      final notificationsRef = _firestore
          .collection('users')
          .doc(_userId)
          .collection('notifications')
          .where('isRead', isEqualTo: false);
          
      final querySnapshot = await notificationsRef.get();
      
      for (var doc in querySnapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      
      await batch.commit();
    }
    
    await _loadNotifications();
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    await _repository.deleteNotification(notificationId);
    
    // Also delete from Firestore if using it
    if (_userId != null) {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('notifications')
          .doc(notificationId)
          .delete();
    }
    
    await _loadNotifications();
  }

  // Clear all notifications
  Future<void> clearAllNotifications() async {
    await _repository.deleteAllNotifications();
    
    // Also clear from Firestore if using it
    if (_userId != null) {
      final batch = _firestore.batch();
      
      final notificationsRef = _firestore
          .collection('users')
          .doc(_userId)
          .collection('notifications');
          
      final querySnapshot = await notificationsRef.get();
      
      for (var doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
    }
    
    await _loadNotifications();
  }

  // Clean up
  @override
  void dispose() {
    _notificationsSubscription?.cancel();
    _medicationsSubscription?.cancel();
    _eventsSubscription?.cancel();
    super.dispose();
  }
}