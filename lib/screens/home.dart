import 'package:africulture/02_iot/screens/dashboard.dart';
import 'package:africulture/08_community/forum_page.dart';
import 'package:africulture/05_hire/screens/hire_page.dart';
import 'package:africulture/04_news/screens/news_screen.dart';
import 'package:africulture/09_profile/user_profile_modal.dart';
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
import 'package:africulture/09_profile/profile.dart';
import '../07_AIassistant/widgets/ai_assistant_popup.dart';
import '/screens/notifications_screen.dart';
import 'package:africulture/09_profile/custom_drawer.dart';
import 'package:weather_icons/weather_icons.dart';

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
        fontFamily: 'Poppins',
        primaryColor: Colors.green[700],
        scaffoldBackgroundColor: const Color(0xFFF1F1F1), // Light Grey
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
  final doc = await FirebaseFirestore.instance
      .collection('farmers')
      .doc(uid)
      .get();
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
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (_isBottomBarVisible) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          setState(() => _isBottomBarVisible = false);
        });
      }
    } else if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
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
      backgroundColor: const Color(0xFFFFFFFF),
      drawer: const CustomDrawer(
        userName: 'John Doe',
        userEmail: 'john@example.com',
        profileImageUrl: 'https://via.placeholder.com/150',
      ),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF00695C),
        title: const Text(
          'Africulture',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),

        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationPage(),
                ),
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
      bottomNavigationBar: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _isBottomBarVisible
            ? BottomNavigationBar(
                backgroundColor: Colors.white,
                currentIndex: myIndex,
                selectedItemColor: Colors.green[800],
                unselectedItemColor: Colors.grey,
                onTap: onTabTapped,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: 'Profile',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.newspaper),
                    label: 'News',
                  ),
                ],
              )
            : const SizedBox.shrink(), // hides it completely with no layout space
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
  bool showPopupBubble = true;

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
      child: Stack(
        children: [
          // Main scrollable content
          SingleChildScrollView(
            controller: widget.scrollController,
            padding: const EdgeInsets.only(
              bottom: 80,
            ), // Add padding so AI icon doesn't overlap content
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
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[900],
                    ),
                  ),
                ),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    const FeatureCard(
                      icon: Icons.thermostat,
                      title: "Weather",
                      destination: WeatherPage(),
                    ),
                    const FeatureCard(
                      icon: Icons.shopping_cart,
                      title: "Market",
                      destination: MarketPage(),
                    ),
                    const FeatureCard(
                      icon: Icons.article,
                      title: "News",
                      destination: NewsPage(),
                    ),
                    const FeatureCard(
                      icon: Icons.forum,
                      title: "Forum",
                      destination: ForumPage(),
                    ),
                    FeatureCard(
                      icon: Icons.fire_truck,
                      title: "Hire",
                      destination: TransportHirePage(),
                    ),
                    const FeatureCard(
                      icon: Icons.devices,
                      title: "IoT Devices",
                      destination: DashboardPage(),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Floating AI button and popup
          Positioned(
            bottom: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (showPopupBubble)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Text("Tap here for AI help!"),
                  ),
                FloatingActionButton(
                  backgroundColor: Colors.greenAccent,
                  onPressed: () {
                    showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (BuildContext context) {
                        return const AIAssistantPopup();
                      },
                    );
                  },
                  child: const Icon(Icons.smart_toy_outlined),
                ),
              ],
            ),
          ),
        ],
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
      height: 180,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            'assets/weather_background.jpg',
          ), // Replace with your asset
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${weatherData['main']['temp'].toStringAsFixed(1)}°C",
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                BoxedIcon(
                  getWeatherIcon(weatherData['weather'][0]['main']),
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  "${weatherData['weather'][0]['main']} • ${weatherData['name']}",
                  style: const TextStyle(fontSize: 18, color: Colors.white70),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _iconInfo(
                  WeatherIcons.strong_wind,
                  "${weatherData['wind']['speed']} km/h",
                ),
                _iconInfo(
                  WeatherIcons.humidity,
                  "${weatherData['main']['humidity']}%",
                ),
                _iconInfo(
                  WeatherIcons.barometer,
                  "${weatherData['main']['pressure']} hPa",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconInfo(IconData icon, String value) {
    return Column(
      children: [
        BoxedIcon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14, color: Colors.white)),
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
      color: const Color(0xFF9EECC2), // Lime Green background
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        ),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: Color(0xFF00695C)), // Deep Teal icons
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF212121), // Charcoal text
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


IconData getWeatherIcon(String condition) {
  switch (condition.toLowerCase()) {
    case 'clear':
      return WeatherIcons.day_sunny;
    case 'clouds':
      return WeatherIcons.cloud;
    case 'rain':
      return WeatherIcons.rain;
    case 'drizzle':
      return WeatherIcons.showers;
    case 'thunderstorm':
      return WeatherIcons.thunderstorm;
    case 'snow':
      return WeatherIcons.snow;
    case 'mist':
    case 'fog':
    case 'haze':
      return WeatherIcons.fog;
    default:
      return WeatherIcons.day_sunny_overcast;
  }
}