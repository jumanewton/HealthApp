import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Keep this for backward compatibility (used in MedicationsPage)
  bool get isLoggedIn => _auth.currentUser != null;

  // Simplified user access
  User? get currentUser => _auth.currentUser;

  // Get user ID (throws if not logged in)
  String get userId {
    if (!isLoggedIn) throw Exception('User not logged in');
    return _auth.currentUser!.uid;
  }

  // Get the current user (returns null if not logged in)
  Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }

  // Sign out with error handling
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('Failed to sign out: $e');
      rethrow;
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      await _auth.currentUser?.delete();
    } catch (e) {
      debugPrint('Failed to delete account: $e');
      rethrow;
    }
  }

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
