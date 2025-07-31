import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

class AuthService with ChangeNotifier{
  static final _functions = FirebaseFunctions.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<bool> isAdmin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    await user.getIdToken(true);
    final idTokenResult = await user.getIdTokenResult();
    return idTokenResult.claims?['admin'] == true;
  }

  static Future<void> grantAdmin(String targetUserId, String targetEmail) async {
    try {
      final result = await _functions
          .httpsCallable('addAdminRole')
          .call({
        'uid': targetUserId,
        'email': targetEmail,
      });
      print(result.data);
    } catch (e) {
      print('Error granting admin: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    notifyListeners();
  }

  static Future<void> approveProduct(String productId) async {
    try {
      final result = await _functions
          .httpsCallable('approveProduct')
          .call({'productId': productId});
      return result.data;
    } catch (e) {
      print('Error approving product: $e');
      rethrow;
    }
  }
}