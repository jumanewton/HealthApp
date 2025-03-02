import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreUtils {
  static Future<void> createUserDocument(UserCredential userCredential, String username) async {
    if (userCredential.user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.email)
          .set({
        'email': userCredential.user!.email,
        'username': username,
      });
    }
  }

  static Future<String?> fetchUsername(String email) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(email)
          .get();

      if (userDoc.exists) {
        return userDoc.data()!['username'];
      }
    } catch (e) {
      return null;
    }
    return null;
  }
}