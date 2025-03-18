// lib/services/medication_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/medication.dart';
import 'auth_service.dart';

class MedicationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  // Get medications as a stream
  Stream<List<Medication>> getMedications() {
    return _firestore
        .collection('users/${_authService.userId}/medications')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Medication.fromFirestore(doc)).toList();
    });
  }

  // Add a new medication
  Future<String> addMedication(Medication medication) async {
    final docRef = await _firestore
        .collection('users/${_authService.userId}/medications')
        .add(medication.toMap());
    return docRef.id;
  }

  // Update an existing medication
  Future<void> updateMedication(Medication medication) async {
    await _firestore
        .collection('users/${_authService.userId}/medications')
        .doc(medication.id)
        .update(medication.toMap());
  }

  // Delete a medication
  Future<void> deleteMedication(String id) async {
    await _firestore
        .collection('users/${_authService.userId}/medications')
        .doc(id)
        .delete();
  }
}