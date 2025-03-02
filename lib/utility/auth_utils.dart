import 'package:firebase_auth/firebase_auth.dart';

class AuthUtils {
  static Future<UserCredential?> registerUser(String email, String password) async {
    try {
      return await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw e;
    }
  }
}