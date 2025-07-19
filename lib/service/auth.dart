import 'package:africulture/pages/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';


class AuthMethods {
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<User?>? getCurrentUser() async {
    return await auth.currentUser;
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    final GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: ['email'],
      // Optional: Only needed if Firebase throws a web client error
      clientId: '771225555427-2mirv8fg96bud6mlv1ca058rhp6bh3cu.apps.googleusercontent.com',
    );

    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) return; // canceled

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    UserCredential result = await FirebaseAuth.instance.signInWithCredential(credential);
    User? user = result.user;

    if (user != null) {
      // ✅ Proceed to your home page
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MyHomePage()));
    }
  }


//   Future<User> signInWithApple({List<Scope> scopes = const []}) async {
//     final result = await TheAppleSignIn.performRequests(
//         [AppleIdRequest(requestedScopes: scopes)]);
//     switch (result.status) {
//       case AuthorizationStatus.authorized:
//         final AppleIdCredential = result.credential!;
//         final oAuthCredential = OAuthProvider('apple.com');
//         final credential = oAuthCredential.credential(
//             idToken: String.fromCharCodes(AppleIdCredential.identityToken!));
//         final UserCredential = await auth.signInWithCredential(credential);
//         final firebaseUser = UserCredential.user!;
//         if (scopes.contains(Scope.fullName)) {
//           final fullName = AppleIdCredential.fullName;
//           if (fullName != null &&
//               fullName.givenName != null &&
//               fullName.familyName != null) {
//             final displayName = '${fullName.givenName}${fullName.familyName}';
//             await firebaseUser.updateDisplayName(displayName);
//           }
//         }
//         return firebaseUser;
//       case AuthorizationStatus.error:
//         throw PlatformException(
//             code: 'ERROR_AUTHORIZATION_DENIED',
//             message: result.error.toString());
//
//       case AuthorizationStatus.cancelled:
//         throw PlatformException(
//             code: 'ERROR_ABORTED_BY_USER', message: 'Sign in aborted by user');
//       default:
//         throw UnimplementedError();
//     }
//   }
}