import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreUtils {
  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; //  Add this line

  static Future<void> createUserDocument(
      UserCredential userCredential, String username) async {
    if (userCredential.user != null) {
      await _firestore.collection('users').doc(userCredential.user!.email).set({
        'email': userCredential.user!.email,
        'username': username,
      });
    }
  }

  static Future<String?> fetchUsername(String email) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userDoc =
          await _firestore.collection('users').doc(email).get();

      if (userDoc.exists) {
        return userDoc.data()?['username']; //  Use null-safe access
      }
    } catch (e) {
      print("DEBUG: Error fetching username: $e");
      return null;
    }
    return null;
  }

  // Function to fetch user data by email
  static Future<Map<String, dynamic>?> getUserData(String email) async {
    try {
      var querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.data(); //  Return user data
      } else {
        print("DEBUG: No user found with email $email");
        return null;
      }
    } catch (e) {
      print("DEBUG: Error fetching user data: $e");
      return null;
    }
  }

  static Future<String?> fetchFirstName(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        String fullName = userDoc['fullName'] ??
            ""; // Get fullName or default to empty string
        return fullName.trim().split(" ")[0]; // Extract first name
      }
      return null;
    } catch (e) {
      print("Error fetching first name: $e");
      return null;
    }
  }
}
