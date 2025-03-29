import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/health_record.dart';

class HealthRecordService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Reference to the user's health records collection
  CollectionReference<Map<String, dynamic>> get _healthRecordsCollection {
    return _firestore
        .collection('Users')
        .doc(currentUserId)
        .collection('healthRecords');
  }

  // Stream of health records for the current user
  Stream<List<HealthRecord>> getHealthRecords() {
    if (currentUserId == null) {
      return Stream.value([]);
    }

    return _healthRecordsCollection
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => HealthRecord.fromFirestore(doc))
          .toList();
    });
  }

  // Upload a health record document
  Future<void> uploadHealthRecord({
    required File file,
    required String title,
    required String type,
  }) async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    // Generate a unique file name
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
    final Reference storageRef = _storage.ref().child('health_records/$currentUserId/$fileName');

    // Upload file to Firebase Storage
    final uploadTask = storageRef.putFile(file);
    final snapshot = await uploadTask;
    final downloadUrl = await snapshot.ref.getDownloadURL();

    // Add record to Firestore
    await _healthRecordsCollection.add({
      'title': title,
      'date': DateTime.now().toString().substring(0, 10),
      'type': type,
      'url': downloadUrl,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Update a health record (metadata only)
  Future<void> updateRecord(HealthRecord record) async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    await _healthRecordsCollection.doc(record.id).update({
      'title': record.title,
      'type': record.type,
      // We don't update the URL here as that would require a new file upload
    });
  }

  // Delete a health record
  Future<void> deleteHealthRecord(String recordId) async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    // Get the record to find the storage URL
    final recordDoc = await _healthRecordsCollection.doc(recordId).get();
    final data = recordDoc.data();
    
    if (data != null && data['url'] != null) {
      // Delete from storage if URL exists
      try {
        final storageRef = FirebaseStorage.instance.refFromURL(data['url']);
        await storageRef.delete();
      } catch (e) {
        print('Error deleting file from storage: $e');
      }
    }

    // Delete from Firestore
    await _healthRecordsCollection.doc(recordId).delete();
  }
}