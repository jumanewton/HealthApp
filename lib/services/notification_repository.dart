// lib/services/notification_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser!.uid;

  // Collection reference
  CollectionReference get _notificationsCollection =>
      _firestore.collection('users').doc(_userId).collection('notifications');

  // Stream of notifications
  Stream<List<NotificationModel>> getNotifications() {
    return _notificationsCollection
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return NotificationModel.fromMap(
            doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Add a new notification
  Future<void> addNotification(NotificationModel notification) {
    return _notificationsCollection.add(notification.toMap());
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) {
    return _notificationsCollection.doc(notificationId).update({'isRead': true});
  }

  // Delete a notification
  Future<void> deleteNotification(String notificationId) {
    return _notificationsCollection.doc(notificationId).delete();
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    final batch = _firestore.batch();
    final notifications = await _notificationsCollection
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in notifications.docs) {
      batch.update(doc.reference, {'isRead': true});
    }

    return batch.commit();
  }

  // Generate medication reminder notification
  Future<void> createMedicationReminder(
      String medicationId, String medicationName, String dosage, String schedule) {
    final notification = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: 'Medication',
      title: 'Medication Reminder',
      description: 'Time to take $medicationName ($dosage). $schedule',
      timestamp: DateTime.now(),
      additionalData: {'medicationId': medicationId},
    );
    
    return addNotification(notification);
  }
  
  // Generate health insight notification
  Future<void> createHealthInsight(
      String title, String message, {Map<String, dynamic>? data}) {
    final notification = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: 'Health Tip',
      title: title,
      description: message,
      timestamp: DateTime.now(),
      additionalData: data,
    );
    
    return addNotification(notification);
  }
}