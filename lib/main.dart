import 'package:africulture/forgot_password.dart';
import 'package:africulture/screens/login_page.dart';
import 'package:africulture/screens/signup_page.dart';
import 'package:africulture/pages/profile.dart';
import 'package:africulture/screens/splash_screen.dart';
import 'package:africulture/pages/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '/pages/phone_signin.dart';
import 'package:africulture/pages/edit_profile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),

      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUp(),
        '/home': (context) => const MyHomePage(),
        '/forgot_password': (context) => const ForgotPassword(),
        '/phone-signin': (context) => const PhoneSignInPage(),
        '/edit_profile': (context) => EditProfilePage(uid: FirebaseAuth.instance.currentUser!.uid,),
        '/profile': (context) {
          final user = FirebaseAuth.instance.currentUser;
          return user != null ? ProfilePage(user: user) : const LoginPage();
        },
      },
    );
  }
}
