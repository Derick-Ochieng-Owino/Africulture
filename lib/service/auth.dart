import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthMethods with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  bool _isSigningIn = false;
  bool get isSigningIn => _isSigningIn;

  Future<void> signInWithGoogle(BuildContext context) async {
    if (_isSigningIn) {
      debugPrint("Already signing in, skipping...");
      return;
    }

    try {
      _isSigningIn = true;
      notifyListeners();
      debugPrint("START: Google Sign-In");

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        debugPrint("User canceled Google sign-in");
        return;
      }

      debugPrint("Google user: ${googleUser.email}");

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      debugPrint("Access Token: ${googleAuth.accessToken}");
      debugPrint("ID Token: ${googleAuth.idToken}");

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      debugPrint("Signed in as: ${userCredential.user?.email}");

      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      debugPrint("ERROR during Google sign-in: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Google Sign-In Failed: $e")),
      );
    } finally {
      _isSigningIn = false;
      notifyListeners();
      debugPrint("END: Google Sign-In");
    }
  }
}
