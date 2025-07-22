import 'package:africulture/02_iot/screens/dashboard.dart';
import 'package:africulture/forum_page.dart';
import 'package:africulture/05_hire/screens/hire_page.dart';
import 'package:africulture/04_news/screens/news_screen.dart';
import 'package:africulture/screens/user_profile_modal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:africulture/03_weather/screens/weather_page.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import '../06_market/screens/market_place.dart';
import '../03_weather/services/weather_service.dart';
import '../01_location/services/location_service.dart';
import 'package:africulture/screens/profile.dart';
import '/screens/notifications_screen.dart';
import 'package:africulture/widgets/custom_drawer.dart';

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
      title: 'Africulture',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Arial',
        primaryColor: Colors.green[700],
        scaffoldBackgroundColor: const Color(0xFFF5FBEF),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black87),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

Future<void> checkProfileAndShowModal(BuildContext context, String uid) async {
  final doc = await FirebaseFirestore.instance.collection('farmers').doc(uid).get();
  final data = doc.data();
  final isComplete = data != null && (data['profileComplete'] == true);

  if (!isComplete) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => UserProfileModal(uid: uid),
    );
  }
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

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        checkProfileAndShowModal(context, currentUser.uid);
      });
    }
  }

  void _scrollListener() {
    if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      if (_isBottomBarVisible) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          setState(() => _isBottomBarVisible = false);
        });
      }
    } else if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
      if (!_isBottomBarVisible) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          setState(() => _isBottomBarVisible = true);
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
      drawer: const CustomDrawer(
        userName: 'John Doe',
        userEmail: 'john@example.com',
        profileImageUrl: 'https://via.placeholder.com/150',
      ),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.green,
        title: const Text(
          'Africulture',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black87),
            onPressed: () {
              Scaffold.of(context).openDrawer(); // ✅ Open the drawer
            },
          ),
        ),

        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black87),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationPage()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() => myIndex = index);
        },
        children: [
          HomePageContent(scrollController: _scrollController),
          FirebaseAuth.instance.currentUser != null
              ? ProfilePage(user: FirebaseAuth.instance.currentUser!)
              : const Center(child: Text("Not logged in")),
          const NewsPage(),
        ],
      ),
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: _isBottomBarVisible ? kBottomNavigationBarHeight : 0,
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          currentIndex: myIndex,
          selectedItemColor: Colors.green[800],
          unselectedItemColor: Colors.grey,
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

class HomePageContent extends StatefulWidget {
  final ScrollController scrollController;

  const HomePageContent({super.key, required this.scrollController});

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  Map<String, dynamic>? _weatherData;
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    try {
      final position = await LocationService.getCurrentLocation();
      final data = await WeatherService.fetchWeatherByCoords(
        position.latitude,
        position.longitude,
      );
      setState(() {
        _weatherData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load weather: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        controller: widget.scrollController,
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error.isNotEmpty
                  ? Text(_error)
                  : WeatherSummaryCard(
                weatherData: _weatherData!,
                isLoading: _isLoading,
                error: _error,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Quick Actions",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green[900]),
              ),
            ),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: const [
                FeatureCard(icon: Icons.thermostat, title: "Weather", destination: WeatherPage()),
                FeatureCard(icon: Icons.shopping_cart, title: "Market", destination: MarketPage()),
                FeatureCard(icon: Icons.article, title: "News", destination: NewsPage()),
                FeatureCard(icon: Icons.forum, title: "Forum", destination: ForumPage()),
                FeatureCard(icon: Icons.fire_truck, title: "Hire", destination: HirePage()),
                FeatureCard(icon: Icons.devices, title: "IoT Devices", destination: DashboardPage()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class WeatherSummaryCard extends StatelessWidget {
  final Map<String, dynamic> weatherData;
  final bool isLoading;
  final String error;

  const WeatherSummaryCard({
    super.key,
    required this.weatherData,
    required this.isLoading,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFB5E655), Color(0xFFE4F89A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${weatherData['main']['temp'].toStringAsFixed(1)}°C",
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 4),
          Text(
            "${weatherData['weather'][0]['main']} • ${weatherData['name']}",
            style: const TextStyle(fontSize: 18, color: Colors.black54),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _iconInfo(Icons.air, "${weatherData['wind']['speed']} km/h"),
              _iconInfo(Icons.water_drop, "${weatherData['main']['humidity']}%"),
              _iconInfo(Icons.invert_colors, "${weatherData['main']['pressure']} hPa"),
            ],
          )
        ],
      ),
    );
  }

  Widget _iconInfo(IconData icon, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.green[800], size: 24),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14)),
      ],
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
    return Material(
      elevation: 4,
      color: const Color(0xFFE8F8BF),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => destination)),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: Colors.green[900]),
              const SizedBox(height: 10),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
