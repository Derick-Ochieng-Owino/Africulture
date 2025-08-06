import 'package:africulture/06_market/screens/add_product_page.dart';
import 'package:africulture/10_authenticication/forgot_password.dart';
import 'package:africulture/10_authenticication/login_page.dart';
import 'package:africulture/10_authenticication/signup_page.dart';
import 'package:africulture/09_profile/profile.dart';
import 'package:africulture/11_home/screens/splash_screen.dart';
import 'package:africulture/11_home/screens/home.dart';
import 'package:africulture/10_authenticication/auth.dart';
import 'package:africulture/03_weather/screens/weather_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:africulture/10_authenticication/phone_signin.dart';
import 'package:africulture/09_profile/edit_profile.dart';
import 'package:provider/provider.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:africulture/08_community/forum_page.dart';
import 'package:africulture/06_market/screens/account_screen.dart';
import 'package:africulture/06_market/screens/admin_dashboard.dart';
import 'package:africulture/06_market/screens/agricommerce.dart';
import 'package:africulture/06_market/screens/cart_screen.dart';
import 'package:africulture/06_market/screens/categories_screen.dart';
import 'package:africulture/06_market/screens/product_detail.dart';
import 'package:africulture/06_market/screens/products_screen.dart';
import 'package:africulture/06_market/screens/search_screen.dart';
import 'package:africulture/06_market/services/auth_service.dart';
import 'package:africulture/06_market/services/cart_service.dart';
import 'package:africulture/06_market/services/product_service.dart';
import 'package:africulture/06_market/widgets/error_boundary.dart';

Future<void> main() async {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
  };
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  try {
    // Initialize Firebase with fallback values
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: dotenv.get('FIREBASE_API_KEY', fallback: ''),
        authDomain: dotenv.get('FIREBASE_AUTH_DOMAIN', fallback: ''),
        projectId: dotenv.get('FIREBASE_PROJECT_ID', fallback: ''),
        storageBucket: dotenv.get('FIREBASE_STORAGE_BUCKET', fallback: ''),
        messagingSenderId: dotenv.get('FIREBASE_MESSAGING_SENDER_ID', fallback: ''),
        appId: dotenv.get('FIREBASE_APP_ID', fallback: ''),
      ),
    );

    if (!kIsWeb) {
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.debug,
        appleProvider: AppleProvider.debug,
      );
    }

    final localizationDelegate = await LocalizationDelegate.create(
      fallbackLocale: 'en',
      supportedLocales: ['en', 'sw'],
      basePath: 'assets/locale/',
    );

    runApp(
      ErrorBoundary(
        child: LocalizedApp(
          localizationDelegate,
          ChangeNotifierProvider(
            create: (_) => AuthMethods(),
            child: const MyApp(),
          ),
        ),
      ),
    );
  } catch (e) {
    runApp(
        const MaterialApp(
          home: Scaffold(
            body: Center(child: Text('Application initialization failed')),
          ),
        ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localizationDelegate = LocalizedApp.of(context).delegate;

    final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthMethods()),
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => ProductService()),
        ChangeNotifierProvider(create: (_) => CartService()),
      ],
      child: MaterialApp(
            navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        localizationsDelegates: [
          localizationDelegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
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
          '/product_detail': (context) => ProductDetailScreen(),
          '/add-product': (context) => ProductAddPage(),
          '/cart': (context) => const CartScreen(),
          '/search': (context) => const SearchScreen(),
          '/account': (context) => const AccountScreen(),
          '/edit_profile': (context) {
            final user = FirebaseAuth.instance.currentUser;
            return user == null
                ? const LoginPage()
                : EditProfilePage(uid: user.uid);
          },
          '/admin': (context) => FutureBuilder<bool>(
            future: AuthService.isAdmin(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }
              if (snapshot.hasError) {
                return const Scaffold(body: Center(child: Text('Error checking admin status')));
              }
              if (snapshot.data == true) {
                return const AdminDashboard();
              }
              return const Scaffold(body: Center(child: Text('Admin access required')));
            },
          ),
        },
      ),
    );
  }
}