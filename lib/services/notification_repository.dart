// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../models/notification_model.dart';

// class NotificationRepository {
//   final FirebaseFirestore _firestore;
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   NotificationRepository({FirebaseFirestore? firestore})
//       : _firestore = firestore ?? FirebaseFirestore.instance;

//   String get _userId => _auth.currentUser!.uid;

//   // Collection reference for nested approach
//   CollectionReference get _userNotificationsCollection =>
//       _firestore.collection('users').doc(_userId).collection('notifications');
  
//   // Collection reference for flat structure approach
//   CollectionReference get _notificationsCollection =>
//       _firestore.collection('notifications');

//   // Stream of notifications (nested structure)
//   Stream<List<NotificationModel>> getNotifications() {
//     return _userNotificationsCollection
//         .orderBy('timestamp', descending: true)
//         .snapshots()
//         .map((snapshot) {
//       return snapshot.docs.map((doc) {
//         return NotificationModel.fromMap(
//             doc.data() as Map<String, dynamic>, doc.id);
//       }).toList();
//     });
//   }
  
//   // Stream of notifications (flat structure)
//   Stream<List<NotificationModel>> notificationsStream(String userId) {
//     return _notificationsCollection
//         .where('userId', isEqualTo: userId)
//         .orderBy('timestamp', descending: true)
//         .snapshots()
//         .map((snapshot) {
//       return snapshot.docs.map((doc) {
//         return NotificationModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
//       }).toList();
//     });
//   }

//   // Get all notifications for current user
//   Future<List<NotificationModel>> getAllNotifications() async {
//     final snapshot = await _userNotificationsCollection
//         .orderBy('timestamp', descending: true)
//         .get();
        
//     return snapshot.docs.map((doc) {
//       return NotificationModel.fromMap(
//           doc.data() as Map<String, dynamic>, doc.id);
//     }).toList();
//   }
  
//   // Get unread count
//   Future<int> getUnreadCount() async {
//     final snapshot = await _userNotificationsCollection
//         .where('isRead', isEqualTo: false)
//         .count()
//         .get();
    
//     return snapshot.count;
//   }

//   // Add a new notification (uses nested structure)
//   Future<void> addNotification(NotificationModel notification) {
//     return _userNotificationsCollection.add(notification.toMap());
//   }
  
//   // Insert notification (preserving ID)
//   Future<void> insertNotification(NotificationModel notification) async {
//     return _userNotificationsCollection.doc(notification.id).set(notification.toMap());
//   }

//   // Mark notification as read
//   Future<void> markAsRead(String notificationId) {
//     return _userNotificationsCollection.doc(notificationId).update({'isRead': true});
//   }

//   // Delete a notification
//   Future<void> deleteNotification(String notificationId) {
//     return _userNotificationsCollection.doc(notificationId).delete();
//   }
  
//   // Delete all notifications
//   Future<void> deleteAllNotifications() async {
//     final batch = _firestore.batch();
//     final docs = await _userNotificationsCollection.get();
    
//     for (var doc in docs.docs) {
//       batch.delete(doc.reference);
//     }
    
//     return batch.commit();
//   }

//   // Mark all notifications as read
//   Future<void> markAllAsRead() async {
//     final batch = _firestore.batch();
//     final notifications = await _userNotificationsCollection
//         .where('isRead', isEqualTo: false)
//         .get();

//     for (var doc in notifications.docs) {
//       batch.update(doc.reference, {'isRead': true});
//     }

//     return batch.commit();
//   }

//   // Generate medication reminder notification
//   Future<void> createMedicationReminder(
//       String medicationId, String medicationName, String dosage, String schedule) {
//     final notification = NotificationModel(
//       id: DateTime.now().millisecondsSinceEpoch.toString(),
//       type: 'Medication',
//       title: 'Medication Reminder',
//       description: 'Time to take $medicationName ($dosage). $schedule',
//       timestamp: DateTime.now(),
//       additionalData: {'medicationId': medicationId},
//     );
    
//     return addNotification(notification);
//   }
  
//   // Generate health insight notification
//   Future<void> createHealthInsight(
//       String title, String message, {Map<String, dynamic>? data}) {
//     final notification = NotificationModel(
//       id: DateTime.now().millisecondsSinceEpoch.toString(),
//       type: 'Health Tip',
//       title: title,
//       description: message,
//       timestamp: DateTime.now(),
//       additionalData: data,
//     );
    
//     return addNotification(notification);
//   }
// }