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
import 'package:flutter/foundation.dart'; // Added for kIsWeb
import 'screens/auth/phone_signin.dart';
import 'package:africulture/screens/edit_profile.dart';
import 'package:provider/provider.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '08_community/forum_page.dart';
import '06_market/screens/market_place.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('1. App starting...');
  await dotenv.load();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: dotenv.get('FIREBASE_API_KEY'),
      authDomain: dotenv.get('FIREBASE_AUTH_DOMAIN'),
      projectId: dotenv.get('FIREBASE_PROJECT_ID'),
      storageBucket: dotenv.get('FIREBASE_STORAGE_BUCKET'),
      messagingSenderId: dotenv.get('FIREBASE_MESSAGING_SENDER_ID'),
      appId: dotenv.get('FIREBASE_APP_ID'),
    ),
  );

  // Only initialize App Check if not on web
  if (!kIsWeb) {
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.debug,
      appleProvider: AppleProvider.debug,
    );
  }

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
        '/profile': (context) {
          final user = FirebaseAuth.instance.currentUser;
          if (user == null) {
            Future.microtask(() => Navigator.pushReplacementNamed(context, '/login'));
            return const SizedBox();
          }
          return ProfilePage(user: user);
        },
        '/forgot_password': (context) => const ForgotPassword(),
        '/phone-signin': (context) => const PhoneSignInPage(),
        '/edit_profile': (context) {
          final user = FirebaseAuth.instance.currentUser;
          if (user == null) {
            Future.microtask(() => Navigator.pushReplacementNamed(context, '/login'));
            return const SizedBox();
          }
          return EditProfilePage(uid: user.uid);
        },
      },
    );
  }
}