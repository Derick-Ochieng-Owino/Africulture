import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static Future<bool> isAdmin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    // Get the ID token result which contains claims
    final idTokenResult = await user.getIdTokenResult();
    return idTokenResult.claims?['admin'] == true;
  }
}