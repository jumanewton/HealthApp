// services/emergency_contact_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/emergency_contact.dart';

class EmergencyContactService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get the current user's document reference
  DocumentReference<Map<String, dynamic>> get _userDocument {
    final String? userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not logged in');
    }
    return _firestore.collection('users').doc(userId);
  }

  // Get the emergency contacts collection reference
  CollectionReference<Map<String, dynamic>> get _contactsCollection {
    return _userDocument.collection('emergencyContacts');
  }

  // Stream of emergency contacts
  Stream<List<EmergencyContact>> getContactsStream() {
    return _contactsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return EmergencyContact.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // Add a new emergency contact
  Future<void> addContact(EmergencyContact contact) async {
    await _contactsCollection.add(contact.toMap());
  }

  // Update an existing emergency contact
  Future<void> updateContact(EmergencyContact contact) async {
    if (contact.id == null) {
      throw Exception('Contact ID cannot be null for updates');
    }
    await _contactsCollection.doc(contact.id).update(contact.toMap());
  }

  // Delete an emergency contact
  Future<void> deleteContact(String contactId) async {
    await _contactsCollection.doc(contactId).delete();
  }

  // Check if user has any emergency contacts
  Future<bool> hasEmergencyContacts() async {
    final snapshot = await _contactsCollection.limit(1).get();
    return snapshot.docs.isNotEmpty;
  }
}