import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutterwave_standard/flutterwave.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentService {
  static Future<Map<String, String>> _getUserDetails() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception("No user logged in");
    }

    // Default values
    String name = user.displayName ?? "Africulture User";
    String email = user.email ?? "user@example.com";
    String phone = "";

    // Try to get phone from Firebase Auth directly
    if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty) {
      phone = user.phoneNumber!;
    }

    // If phone not set in Auth, try Firestore profile
    if (phone.isEmpty) {
      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();
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
        txRef: DateTime.now().millisecondsSinceEpoch.toString(),
        paymentOptions: "card, mobilemoney, ussd",
        customization: Customization(title: "Africulture Checkout"),
        redirectUrl: "https://your-redirect-url.com",
        isTestMode: dotenv.env['FLUTTER_WAVE_TEST_MODE'] == 'true',
      );

      final ChargeResponse? response = await flutterwave.charge(context);

      if (response != null && response.success == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Payment successful!")),
        );
        if (onSuccess != null) onSuccess();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Payment cancelled or failed.")),
        );
        if (onFailure != null) onFailure();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }
}
