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
import 'service/weather_service.dart';
import 'service/location_service.dart';

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
        leading: IconButton(
          icon: Icon(Icons.person),
          color: Colors.white,
          onPressed: () {
            // Handle profile tap
          },
        ),
        title: const Text('Africulture'),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            color: Colors.white,
            onPressed: () {
              // Handle notification tap
            },
          ),
        ],
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
      // Get current location
      final position = await LocationService.getCurrentLocation();
      print("Latitude: ${position.latitude}, Longitude: ${position.longitude}");

      // Fetch weather using coordinates
      final data = await WeatherService.fetchWeatherByCoords(
        position.latitude,
        position.longitude,
      );

      setState(() {
        _weatherData = data;
        _isLoading = false;
        _error = '';
      });

      print("Weather Data: $_weatherData");
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

              // Weather Card (Dynamic)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : _error.isNotEmpty
                    ? Text(_error)
                    : WeatherSummaryCard(
                ),
              ),

              // ✅ Grid of features
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
          )

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

class WeatherSummaryCard extends StatefulWidget {
  const WeatherSummaryCard({super.key});

  @override
  State<WeatherSummaryCard> createState() => _WeatherSummaryCardState();
}

class _WeatherSummaryCardState extends State<WeatherSummaryCard> {
  Map<String, dynamic>? weatherData;
  bool isLoading = true;
  String error = '';

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
        weatherData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Error fetching weather: $e';
        isLoading = false;
      });
    }
  }

  LinearGradient _getGradient(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return LinearGradient(colors: [Colors.orange, Colors.yellow]);
      case 'rain':
        return LinearGradient(colors: [Colors.blueGrey, Colors.blue]);
      case 'clouds':
        return LinearGradient(colors: [Colors.grey.shade600, Colors.grey.shade300]);
      case 'thunderstorm':
        return LinearGradient(colors: [Colors.indigo, Colors.deepPurple]);
      default:
        return LinearGradient(colors: [Colors.green.shade700, Colors.green.shade400]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const WeatherPage()));
      },
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error.isNotEmpty
          ? Text(error)
          : Card(
        elevation: 4,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: _getGradient(weatherData!['weather'][0]['main']),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                weatherData!['name'],
                style: const TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "${weatherData!['weather'][0]['main']} | ${weatherData!['main']['temp'].toStringAsFixed(1)}°C",
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

