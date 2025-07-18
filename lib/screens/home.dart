import 'package:africulture/forum_page.dart';
import 'package:africulture/hire_page.dart';
import 'package:africulture/news_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:africulture/weather_page.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import '../iot_devices_screen.dart';
import '../market_place.dart';
import '../service/weather_service.dart';
import '../service/location_service.dart';
import 'package:africulture/screens/profile.dart';
import '/screens/notifications_screen.dart';

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
        primarySwatch: Colors.green, // Your green color scheme
      ),
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.person, color: Colors.white),
          onPressed: () {
            final currentUser = FirebaseAuth.instance.currentUser;
            if (currentUser != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(user: currentUser),
                ),
              );
            } else {
              Navigator.pushReplacementNamed(context, '/login');
            }
          },
        ),
        title: const Text('Africulture', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationPage()),
              );
            },
          ),
        ],
        backgroundColor: Colors.green, // Your green app bar
        elevation: 0,
        centerTitle: true,
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
          children: [
            const SizedBox(height: 20),
            const Text(
              'Welcome to Africulture!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : _error.isNotEmpty
                  ? Text(_error)
                  : WeatherSummaryCard(
                weatherData: _weatherData!,
                isLoading: _isLoading,
                error: _error,
              ),
            ),
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

  LinearGradient _getGradient(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return const LinearGradient(colors: [Colors.orange, Colors.yellow]);
      case 'rain':
        return const LinearGradient(colors: [Colors.blueGrey, Colors.blue]);
      case 'clouds':
        return LinearGradient(colors: [Colors.grey.shade600, Colors.grey.shade300]);
      case 'thunderstorm':
        return const LinearGradient(colors: [Colors.indigo, Colors.deepPurple]);
      default:
        return LinearGradient(colors: [Colors.green.shade700, Colors.green.shade400]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WeatherPage())),
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: _getGradient(weatherData['weather'][0]['main']),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                weatherData['name'],
                style: const TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "${weatherData['weather'][0]['main']} | ${weatherData['main']['temp'].toStringAsFixed(1)}°C",
                style: const TextStyle(fontSize: 18, color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
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
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => destination)),
        child: SizedBox(
          height: 120,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 40, color: Colors.green), // Your green icons
                const SizedBox(height: 8),
                Text(title, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

