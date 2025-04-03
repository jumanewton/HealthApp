// // lib/services/health_insights_service.dart
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../providers/notification_provider.dart';

// class HealthInsightsService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final NotificationProvider _notificationProvider;

//   HealthInsightsService(this._notificationProvider);

//   String get _userId => _auth.currentUser!.uid;

//   // Get user medications collection reference
//   CollectionReference get _medicationsCollection =>
//       _firestore.collection('users').doc(_userId).collection('medications');

//   // Generate insights based on user's medication data
//   Future<void> generateMedicationInsights() async {
//     try {
//       final medications = await _medicationsCollection.get();
      
//       if (medications.docs.isEmpty) return;
      
//       // Check for medications that need refills (assuming we have a "remaining" field)
//       for (var med in medications.docs) {
//         final data = med.data() as Map<String, dynamic>;
//         if (data.containsKey('remaining') && (data['remaining'] as num) < 5) {
//           await _notificationProvider.createHealthInsight(
//             'Medication Refill Needed',
//             'You only have ${data['remaining']} doses of ${data['name']} left. Consider getting a refill soon.',
//             data: {'medicationId': med.id, 'actionType': 'refill'},
//           );
//         }
//       }
      
//       // Check for medications that might be taken at the same time
//       // This is a simplified example - you would need more complex logic in a real app
//       final medsGroupedByTime = <String, List<String>>{};
      
//       for (var med in medications.docs) {
//         final data = med.data() as Map<String, dynamic>;
//         if (data.containsKey('reminderTime') && data.containsKey('name')) {
//           final time = '${data['reminderTime']['hour']}:${data['reminderTime']['minute']}';
//           if (!medsGroupedByTime.containsKey(time)) {
//             medsGroupedByTime[time] = [];
//           }
//           medsGroupedByTime[time]!.add(data['name'] as String);
//         }
//       }
      
//       for (var time in medsGroupedByTime.keys) {
//         if (medsGroupedByTime[time]!.length > 1) {
//           final medNames = medsGroupedByTime[time]!.join(', ');
//           await _notificationProvider.createHealthInsight(
//             'Medication Schedule Insight',
//             'You have multiple medications ($medNames) scheduled for the same time. Ensure there are no interactions.',
//             data: {'time': time, 'medications': medsGroupedByTime[time]},
//           );
//         }
//       }
      
//     } catch (e) {
//       print('Error generating health insights: $e');
//     }
//   }
// }