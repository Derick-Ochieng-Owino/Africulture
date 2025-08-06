import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:path/path.dart' as imageUrls;

class AuthMethods with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isSigningIn = false;
  bool get isSigningIn => _isSigningIn;

  Future<void> signInWithGoogle(BuildContext context) async {
    if (_isSigningIn) return;

    try {
      _isSigningIn = true;
      notifyListeners();
      debugPrint("🔐 START: Google Sign-In");

      UserCredential userCredential;

      if (kIsWeb) {
        // ✅ Web Sign-In
        final googleProvider = GoogleAuthProvider();
        googleProvider.setCustomParameters({'login_hint': 'user@example.com'});

        userCredential = await _auth.signInWithPopup(googleProvider);
      } else {
        // ✅ Mobile Sign-In
        final googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) {
          debugPrint("❌ User cancelled Google Sign-In");
          return;
        }

        final googleAuth = await googleUser.authentication;

        if (googleAuth.accessToken == null || googleAuth.idToken == null) {
          debugPrint("❌ Missing Google Auth tokens");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to retrieve Google credentials.")),
          );
          return;
        }

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        userCredential = await _auth.signInWithCredential(credential);
      }

      final user = userCredential.user;
      if (user == null) {
        debugPrint("❌ Firebase user is null");
        return;
      }

      debugPrint("✅ Signed in as: ${user.email}");
      debugPrint(imageUrls.join('\n'));
      debugPrint(imageUrls.join('\n'));
      Navigator.of(context).pushReplacementNamed('/home');
    } catch (e) {
      debugPrint("🚫 Google Sign-In Failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Google Sign-In Failed: $e")),
      );
    } finally {
      _isSigningIn = false;
      notifyListeners();
      debugPrint("🔚 END: Google Sign-In");
    }
  }
}
