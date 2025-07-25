import 'dart:io';

import 'package:africulture/screens/auth/forgot_password.dart';
import 'package:africulture/screens/auth/login_page.dart';
import 'package:africulture/screens/auth/signup_page.dart';
import 'package:africulture/screens/profile.dart';
import 'package:africulture/screens/splash_screen.dart';
import 'package:africulture/screens/home.dart';
import 'package:africulture/service/auth.dart';
import 'package:africulture/03_weather/screens/weather_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'screens/auth/phone_signin.dart';
import 'package:africulture/screens/edit_profile.dart';
import 'package:provider/provider.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '08_community/forum_page.dart';
import '06_market/screens/market_place.dart';


void main() async {
  print("Current directory: ${Directory.current.path}");
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Firebase.initializeApp();

  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug, // Replace with real provider for release builds
    appleProvider: AppleProvider.debug,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthMethods(),
      child: const MyApp(),
    ),
  );
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
        '/signup': (context) => const SignUpPage(),
        '/home': (context) => const MyHomePage(),
        '/market': (context) => const MarketPage(),
        '/weather': (context) => const WeatherPage(),
        '/forum': (context) => const ForumPage(),
        '/profile': (context) => ProfilePage(user: FirebaseAuth.instance.currentUser!), // or however you're passing user
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
