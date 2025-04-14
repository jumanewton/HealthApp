import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import '../models/health_record.dart';

class HealthRecordService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String get _userId => _auth.currentUser?.uid ?? '';

  // Get reference to user's health records collection
  CollectionReference get _recordsCollection => 
      _firestore.collection('users').doc(_userId).collection('healthRecords');

  // Stream of health records for the current user
  Stream<List<HealthRecord>> getHealthRecords() {
    return _recordsCollection
        .orderBy('dateAdded', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => HealthRecord.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Add a new health record with file upload
  Future<HealthRecord> addHealthRecord(
    String title,
    RecordType type,
    File file,
    {String? summary}
  ) async {
    // Upload file to Firebase Storage
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(file.path)}';
    final storageRef = _storage.ref().child('users/$_userId/healthRecords/$fileName');
    
    final uploadTask = storageRef.putFile(file);
    final snapshot = await uploadTask.whenComplete(() => null);
    final downloadUrl = await snapshot.ref.getDownloadURL();
    
    // Create new record document
    final docRef = await _recordsCollection.add({
      'title': title,
      'type': type.toString().split('.').last,
      'url': downloadUrl,
      'dateAdded': FieldValue.serverTimestamp(),
      'summary': summary,
    });
    
    // Return the new health record
    return HealthRecord(
      id: docRef.id,
      title: title,
      type: type,
      url: downloadUrl,
      dateAdded: DateTime.now(),
      summary: summary,
    );
  }

  // Update an existing health record
  Future<void> updateHealthRecord(HealthRecord record, {File? newFile}) async {
    Map<String, dynamic> updateData = record.toMap();
    
    // If a new file is provided, upload it and update the URL
    if (newFile != null) {
      // Delete the old file if it exists
      if (record.url.isNotEmpty) {
        try {
          await _storage.refFromURL(record.url).delete();
        } catch (e) {
          // Ignore errors if the file doesn't exist
        }
      }
      
      // Upload the new file
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(newFile.path)}';
      final storageRef = _storage.ref().child('users/$_userId/healthRecords/$fileName');
      
      final uploadTask = storageRef.putFile(newFile);
      final snapshot = await uploadTask.whenComplete(() => null);
      updateData['url'] = await snapshot.ref.getDownloadURL();
    }
    
    // Update the record in Firestore
    await _recordsCollection.doc(record.id).update(updateData);
  }

  // Delete a health record
  Future<void> deleteHealthRecord(String recordId) async {
    // Get the record to retrieve the file URL
    final docSnapshot = await _recordsCollection.doc(recordId).get();
    final data = docSnapshot.data() as Map<String, dynamic>?;
    final fileUrl = data?['url'] as String?;
    
    // Delete the file from Storage if it exists
    if (fileUrl != null && fileUrl.isNotEmpty) {
      try {
        await _storage.refFromURL(fileUrl).delete();
      } catch (e) {
        // Ignore errors if the file doesn't exist
      }
    }
    
    // Delete the record document
    await _recordsCollection.doc(recordId).delete();
  }

  // Update record with a summary
  Future<void> updateRecordSummary(String recordId, String summary) async {
    await _recordsCollection.doc(recordId).update({'summary': summary});
  }

  // Get a single health record by ID
  Future<HealthRecord?> getHealthRecord(String recordId) async {
    final docSnapshot = await _recordsCollection.doc(recordId).get();
    if (!docSnapshot.exists) return null;
    
    return HealthRecord.fromMap(
      docSnapshot.id, 
      docSnapshot.data() as Map<String, dynamic>
    );
  }
}