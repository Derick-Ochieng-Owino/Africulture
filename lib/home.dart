import 'package:africulture/forum_page.dart';
import 'package:africulture/hire_page.dart';
import 'package:africulture/news.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:africulture/weather_page.dart';
import 'package:flutter/rendering.dart';
import 'iot_devices_screen.dart';
import 'market_place.dart';
import 'login_page.dart';
import 'signup_page.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Africulture',
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUp(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int myIndex = 0;
  late PageController _pageController;
  late ScrollController _scrollController;
  bool _isBottomBarVisible = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      if (_isBottomBarVisible) {
        setState(() {
          _isBottomBarVisible = false;
        });
      }
    } else if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
      if (!_isBottomBarVisible) {
        setState(() {
          _isBottomBarVisible = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void onTabTapped(int index) {
    setState(() {
      myIndex = index;
      _pageController.jumpToPage(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Africulture'),
        backgroundColor: Colors.green,
        elevation: 0,
        centerTitle: true,
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            myIndex = index;
          });
        },
        children: [
          HomePageContent(scrollController: _scrollController),
          const ProfilePage(),
          NewsPage(),
        ],
      ),
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: _isBottomBarVisible ? kBottomNavigationBarHeight : 0,
        child: BottomNavigationBar(
          currentIndex: myIndex,
          onTap: onTabTapped,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
            BottomNavigationBarItem(icon: Icon(Icons.newspaper), label: 'News'),
          ],
        ),
      ),
    );
  }
}

class HomePageContent extends StatelessWidget {
  final ScrollController scrollController;

  const HomePageContent({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.only(bottom: 40), // Increased padding
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              'Welcome to Africulture!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              crossAxisCount: 2,
              padding: const EdgeInsets.all(10),
              children: const [
                FeatureCard(icon: Icons.thermostat, title: "Weather", destination: WeatherPage()),
                FeatureCard(icon: Icons.shopping_cart, title: "Market", destination: MarketPage()),
                FeatureCard(icon: Icons.article, title: "News", destination: NewsPage()),
                FeatureCard(icon: Icons.forum, title: "Forum", destination: ForumPage()),
                FeatureCard(icon: Icons.fire_truck, title: "Hire", destination: HirePage()),
                FeatureCard(icon: Icons.devices, title: "IoT Devices", destination: IoTDevicesScreen()),
                FeatureCard(icon: Icons.thermostat, title: "Weather", destination: WeatherPage()),
                FeatureCard(icon: Icons.shopping_cart, title: "Market", destination: MarketPage()),
                FeatureCard(icon: Icons.article, title: "News", destination: NewsPage()),
                FeatureCard(icon: Icons.forum, title: "Forum", destination: ForumPage()),
                FeatureCard(icon: Icons.fire_truck, title: "Hire", destination: HirePage()),
                FeatureCard(icon: Icons.devices, title: "IoT Devices", destination: IoTDevicesScreen()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Profile Page', style: TextStyle(fontSize: 24)),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget destination;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.destination,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destination),
          );
        },
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40, color: Colors.green),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
