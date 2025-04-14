import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/calendar_event.dart';

class CalendarRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get user events collection reference
  CollectionReference get _eventsCollection {
    return _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('events');
  }

  // Stream all events
  Stream<List<CalendarEvent>> streamEvents() {
    return _eventsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        
        // Determine event type and create appropriate instance
        if (data['category'] == EventCategory.medication.index) {
          return MedicationEvent.fromMap(data);
        }
        
        return CalendarEvent.fromMap(data);
      }).toList();
    });
  }

  // Add an event
  Future<String> addEvent(CalendarEvent event) async {
    await _eventsCollection.doc(event.id).set(event.toMap());
    return event.id;
  }

  // Update an event
  Future<void> updateEvent(CalendarEvent event) async {
    await _eventsCollection.doc(event.id).update(event.toMap());
  }

  // Delete an event
  Future<void> deleteEvent(String eventId) async {
    await _eventsCollection.doc(eventId).delete();
  }

  // Get events for a specific date
  Future<List<CalendarEvent>> getEventsForDate(DateTime date) async {
    // Normalize the date to start of day
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final snapshot = await _eventsCollection
        .where('dateTime', isGreaterThanOrEqualTo: startOfDay)
        .where('dateTime', isLessThan: endOfDay)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      
      // Determine event type and create appropriate instance
      if (data['category'] == EventCategory.medication.index) {
        return MedicationEvent.fromMap(data);
      }
      
      return CalendarEvent.fromMap(data);
    }).toList();
  }

  // Get all recurring events (useful for notification scheduling)
  Future<List<CalendarEvent>> getRecurringEvents() async {
    final snapshot = await _eventsCollection
        .where('recurrence', isNotEqualTo: RecurrencePattern.once.index)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      
      // Determine event type and create appropriate instance
      if (data['category'] == EventCategory.medication.index) {
        return MedicationEvent.fromMap(data);
      }
      
      return CalendarEvent.fromMap(data);
    }).toList();
  }

  // Search events by title
  Future<List<CalendarEvent>> searchEvents(String query) async {
    if (query.isEmpty) return [];

    // This is a simple implementation - for a production app, consider 
    // using Firebase extensions or a more sophisticated search approach
    final snapshot = await _eventsCollection
        .orderBy('title')
        .startAt([query])
        .endAt(['$query\uf8ff'])
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      
      // Determine event type and create appropriate instance
      if (data['category'] == EventCategory.medication.index) {
        return MedicationEvent.fromMap(data);
      }
      
      return CalendarEvent.fromMap(data);
    }).toList();
  }
}
