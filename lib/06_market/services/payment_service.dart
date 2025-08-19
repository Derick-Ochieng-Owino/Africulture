import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutterwave_standard/flutterwave.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static Future<Map<String, String>> _getUserDetails() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception("No user logged in");
    }

    String name = user.displayName ?? "Africulture User";
    String email = user.email ?? "user@example.com";
    String phone = "";

    // Try phone from Auth
    if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty) {
      phone = user.phoneNumber!;
    }

    // If phone not set, try Firestore profile
    if (phone.isEmpty) {
      final doc = await _firestore.collection("users").doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        phone = doc.data()!["phone"] ?? "";
        name = doc.data()!["name"] ?? name;
      }
    }

    return {
      "name": name,
      "email": email,
      "phone": phone.isNotEmpty ? phone : "254700000000",
    };
  }

  static Future<void> startPayment({
    required BuildContext context,
    required double amount,
    Function()? onSuccess,
    Function()? onFailure,
  }) async {
    try {
      final userDetails = await _getUserDetails();
      final user = _auth.currentUser!;
      final txRef = DateTime.now().millisecondsSinceEpoch.toString();

      final customer = Customer(
        name: userDetails["name"]!,
        phoneNumber: userDetails["phone"]!,
        email: userDetails["email"]!,
      );

      final flutterwave = Flutterwave(
        publicKey: dotenv.env['FLUTTER_WAVE_PUBLIC_KEY'] ?? '',
        currency: "KES",
        amount: amount.toString(),
        customer: customer,
        txRef: txRef,
        paymentOptions: "card, mobilemoney, ussd",
        customization: Customization(title: "Africulture Checkout"),
        redirectUrl: "https://your-redirect-url.com",
        isTestMode: dotenv.env['FLUTTER_WAVE_TEST_MODE'] == 'true',
      );

      final ChargeResponse? response = await flutterwave.charge(context);

      final paymentData = {
        "txRef": txRef,
        "userId": user.uid,
        "amount": amount,
        "currency": "KES",
        "status": response?.status ?? "failed",
        "success": response?.success ?? false,
        "userName": userDetails["name"],
        "email": userDetails["email"],
        "phone": userDetails["phone"],
        "createdAt": FieldValue.serverTimestamp(),
      };

      // Save in user’s collection
      await _firestore
          .collection("users")
          .doc(user.uid)
          .collection("payments")
          .doc(txRef)
          .set(paymentData);

      // Save in global payments collection for Admin
      await _firestore.collection("payments").doc(txRef).set(paymentData);

      if (response != null && response.success == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Payment successful!")),
        );
        if (onSuccess != null) onSuccess();
      } else {
        debugPrint('❌ Payment cancelled or failed.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Payment cancelled or failed.")),
        );
        if (onFailure != null) onFailure();
      }
    } catch (e) {
      debugPrint("Payment error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }
}
