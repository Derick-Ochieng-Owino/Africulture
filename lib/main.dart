<<<<<<< HEAD
import 'package:africulture/10_authenticication/forgot_password.dart';
import 'package:africulture/10_authenticication/login_page.dart';
import 'package:africulture/10_authenticication/signup_page.dart';
import 'package:africulture/09_profile/profile.dart';
import 'package:africulture/11_home/screens/splash_screen.dart';
import 'package:africulture/11_home/screens/home.dart';
import 'package:africulture/10_authenticication/auth.dart';
=======
import 'package:africulture/screens/auth/forgot_password.dart';
import 'package:africulture/screens/auth/login_page.dart';
import 'package:africulture/screens/auth/signup_page.dart';
import 'package:africulture/09_profile/profile.dart';
import 'package:africulture/screens/splash_screen.dart';
import 'package:africulture/screens/home.dart';
import 'package:africulture/service/auth.dart';
>>>>>>> 5df6cc5861a138b5fb059e14e406343467db6cc2
import 'package:africulture/03_weather/screens/weather_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_translate/flutter_translate.dart';
<<<<<<< HEAD
import 'package:africulture/10_authenticication/phone_signin.dart';
=======
import 'package:africulture/screens/auth/phone_signin.dart';
>>>>>>> 5df6cc5861a138b5fb059e14e406343467db6cc2
import 'package:africulture/09_profile/edit_profile.dart';
import 'package:provider/provider.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:africulture/08_community/forum_page.dart';
<<<<<<< HEAD
import '06_market/screens/account_screen.dart';
import '06_market/screens/agricommerce.dart';
import '06_market/screens/cart_screen.dart';
import '06_market/screens/categories_screen.dart';
import '06_market/screens/product_detal.dart';
import '06_market/screens/products_screen.dart';
import '06_market/screens/search_screen.dart';
import '06_market/services/cart_service.dart';
import '06_market/services/product_service.dart';
=======
import 'package:africulture/06_market/screens/market_place.dart';
>>>>>>> 5df6cc5861a138b5fb059e14e406343467db6cc2

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Load environment variables
    await dotenv.load(fileName: '.env');

<<<<<<< HEAD
=======
    // Initialize Firebase
>>>>>>> 5df6cc5861a138b5fb059e14e406343467db6cc2
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

<<<<<<< HEAD
=======
    // Initialize localization
>>>>>>> 5df6cc5861a138b5fb059e14e406343467db6cc2
    final localizationDelegate = await LocalizationDelegate.create(
      fallbackLocale: 'en',
      supportedLocales: ['en', 'sw'],
      basePath: 'assets/locale/',
    );

<<<<<<< HEAD
=======
    // Initialize App Check (non-web only)
>>>>>>> 5df6cc5861a138b5fb059e14e406343467db6cc2
    if (!kIsWeb) {
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.debug,
        appleProvider: AppleProvider.debug,
      );
    }

<<<<<<< HEAD
=======
    // Run the app with localization
>>>>>>> 5df6cc5861a138b5fb059e14e406343467db6cc2
    runApp(
      LocalizedApp(
        localizationDelegate,
        ChangeNotifierProvider(
          create: (_) => AuthMethods(),
          child: const MyApp(),
        ),
      ),
    );
  } catch (e) {
<<<<<<< HEAD
    runApp(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Application initialization failed')),
        ),
      ),
    );
=======
    // Fallback app if initialization fails
    runApp(const MaterialApp(
      home: Scaffold(
        body: Center(child: Text('Application initialization failed')),
      ),
    ));
>>>>>>> 5df6cc5861a138b5fb059e14e406343467db6cc2
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    final localizationDelegate = LocalizedApp.of(context).delegate;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthMethods()),
        ChangeNotifierProvider(create: (_) => ProductService()),
        ChangeNotifierProvider(create: (_) => CartService()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        localizationsDelegates: [
          localizationDelegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: localizationDelegate.supportedLocales,
        locale: localizationDelegate.currentLocale,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginPage(),
          '/signup': (context) => const SignUpPage(),
          '/home': (context) => const MyHomePage(),
          '/market': (context) => const AgriCommerceApp(),
          '/weather': (context) => const WeatherPage(),
          '/forum': (context) => const ForumPage(),
          '/profile': (context) {
            final user = FirebaseAuth.instance.currentUser;
            return user == null ? const LoginPage() : ProfilePage(user: user);
          },
          '/forgot_password': (context) => const ForgotPassword(),
          '/phone-signin': (context) => const PhoneSignInPage(),
          '/categories': (context) => const CategoriesScreen(),
          '/products': (context) => const ProductsScreen(),
          '/product_detail': (context) => const ProductDetailScreen(),
          '/cart': (context) => const CartScreen(),
          '/search': (context) => const SearchScreen(),
          '/account': (context) => const AccountScreen(),
          '/edit_profile': (context) {
            final user = FirebaseAuth.instance.currentUser;
            return user == null
                ? const LoginPage()
                : EditProfilePage(uid: user.uid);
          },
=======
    // Get the localization delegate from context
    final localizationDelegate = LocalizedApp.of(context).delegate;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      localizationsDelegates: [
        localizationDelegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: localizationDelegate.supportedLocales,
      locale: localizationDelegate.currentLocale,
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
          return user == null
              ? const LoginPage()
              : ProfilePage(user: user);
        },
        '/forgot_password': (context) => const ForgotPassword(),
        '/phone-signin': (context) => const PhoneSignInPage(),
        '/edit_profile': (context) {
          final user = FirebaseAuth.instance.currentUser;
          return user == null
              ? const LoginPage()
              : EditProfilePage(uid: user.uid);
>>>>>>> 5df6cc5861a138b5fb059e14e406343467db6cc2
        },
      ),
    );
  }
}