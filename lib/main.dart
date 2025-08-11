import 'package:africulture/06_market/screens/add_product_page.dart';
import 'package:africulture/10_authenticication/forgot_password.dart';
import 'package:africulture/10_authenticication/login_page.dart';
import 'package:africulture/10_authenticication/signup_page.dart';
import 'package:africulture/09_profile/profile.dart';
import 'package:africulture/12_Admin/providers/content_provider.dart';
import 'package:africulture/12_Admin/screens/admin_approval_page.dart';
import 'package:africulture/11_home/screens/splash_screen.dart';
import 'package:africulture/11_home/screens/home.dart';
import 'package:africulture/10_authenticication/auth.dart';
import 'package:africulture/03_weather/screens/weather_page.dart';
import 'package:africulture/12_Admin/screens/analytics_screen.dart';
import 'package:africulture/12_Admin/screens/content_screen.dart';
import 'package:africulture/12_Admin/screens/dashboard_screen.dart';
import 'package:africulture/12_Admin/screens/settings_screen.dart';
import 'package:africulture/12_Admin/screens/users_screen.dart';
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
import '12_Admin/providers/admin_provider.dart';
import '12_Admin/providers/analytics_provider.dart';
import '12_Admin/providers/theme_provider.dart';
import '12_Admin/providers/user_provider.dart';
import '12_Admin/screens/notifications_screen.dart';
import '12_Admin/screens/profile_screen.dart';

late final LocalizationDelegate localizationDelegate;

Future<void> main() async {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
  };

  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  try {
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
        webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
        androidProvider: AndroidProvider.debug,
        appleProvider: AppleProvider.debug,
      );
    }

    localizationDelegate = await LocalizationDelegate.create(
      fallbackLocale: 'en',
      supportedLocales: ['en', 'sw'],
      basePath: 'assets/locale/',
    );

    runApp(const MyRoot());
  } catch (e) {
    runApp(const MaterialApp(
      home: Scaffold(
        body: Center(child: Text('Application initialization failed')),
      ),
    ));
  }
}

class MyRoot extends StatelessWidget {
  const MyRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return ErrorBoundary(
      child: LocalizedApp(
        localizationDelegate,
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthMethods()),
            ChangeNotifierProvider(create: (_) => AuthService()),
            ChangeNotifierProvider(create: (_) => ProductService()),
            ChangeNotifierProvider(create: (_) => CartService()),
            ChangeNotifierProvider(create: (_) => AdminProvider()),
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider(create: (_) => AnalyticsProvider()),
            ChangeNotifierProvider(create: (_) => ContentProvider()),
            ChangeNotifierProvider(create: (_) => UserProvider()),
          ],
          child: const MyApp(),
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

    return MaterialApp(
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
        '/adminDashboard': (context) => const DashboardScreen(),
        '/users': (context) => const UsersScreen(),
        '/analytics': (context) => const AnalyticsScreen(),
        '/admin_settings': (context) => const SettingsScreen(),
        '/content_and_posts': (context) => const ContentScreen(),
        '/admin_profile': (context) => const ProfileScreen(),
        '/admin_Notifications': (context) => const AdminNotificationsScreen(),
        '/adminproducts': (context) => const ProductsScreen(),
        '/product_approval': (context) => const AdminApprovalPage(),
      },
    );
  }
}
