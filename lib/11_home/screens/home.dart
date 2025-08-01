// ignore_for_file: deprecated_member_use

import 'dart:ui';
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
import '../../06_market/screens/agricommerce.dart';
import '../widgets/gallery_widget.dart';
import '../widgets/recommendation_widget.dart';
import '/03_weather/services/weather_service.dart';
import '../service/location_service.dart';
import 'package:africulture/09_profile/profile.dart';
import '/07_AIassistant/widgets/ai_assistant_popup.dart';
import '/11_home/screens/notifications_screen.dart';
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
        scaffoldBackgroundColor: const Color(0xFFF5F5F5), // Light Grey
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black87),
        ),
      ),
      home: const MyHomePage(),
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

  String username = '';
  String userEmail = '';
  String profileImageurl = '';

  Future<void> getUserInfo(String uid) async {
    final doc = await FirebaseFirestore.instance.collection('farmers').doc(uid).get();
    final data = doc.data();
    if (data != null) {
      setState(() {
        username = data['name'] ?? '';
        userEmail = data['email'] ?? '';
        profileImageurl = data['photoUrl'] ?? ''; // change based on your field
      });
    }
  }



  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      getUserInfo(currentUser.uid);
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
      backgroundColor: const Color(0xFFE8FFD7),
      drawer: username.isNotEmpty
          ? CustomDrawer(
        userName: username,
        userEmail: userEmail,
        profileImageUrl: profileImageurl,
      )
          : null, // or show a loading drawer or empty

      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF2E7D32),
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
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotificationPage()),
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.language, color: Colors.white),
            onSelected: (String language) {
              // Handle language change
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(value: 'English', child: Text('English')),
              const PopupMenuItem(value: 'Swahili', child: Text('Swahili')),
              const PopupMenuItem(value: 'French', child: Text('French')),
            ],
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => myIndex = index),
        children: [
          HomePageContent(scrollController: _scrollController, userName: username,),
          FirebaseAuth.instance.currentUser != null
              ? ProfilePage(user: FirebaseAuth.instance.currentUser!)
              : const Center(child: Text("Not logged in")),
          const NewsPage(),
        ],
      ),
      bottomNavigationBar: AnimatedSlide(
        duration: const Duration(milliseconds: 300),
        offset: _isBottomBarVisible ? Offset.zero : const Offset(0, 1),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: _isBottomBarVisible ? 1.0 : 0.0,
          child: BottomNavigationBar(
            backgroundColor: Colors.white,
            currentIndex: myIndex,
            selectedItemColor: const Color(0xFF2E7D32), // Dark Green
            unselectedItemColor: Colors.grey,
            onTap: onTabTapped,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
              BottomNavigationBarItem(icon: Icon(Icons.newspaper), label: 'News'),
            ],
          ),
        ),
      ),
    );
  }
}

class HomePageContent extends StatefulWidget {
  final ScrollController scrollController;
  final String userName;

  const HomePageContent({super.key, required this.scrollController, required this.userName});

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
          // Blurred background for the entire page
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
          ),

          // Main content
          SingleChildScrollView(
            controller: widget.scrollController,
            padding: const EdgeInsets.only(bottom: 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Container with improved styling
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8FFD7).withOpacity(0.85),
                    border: Border.all(
                      color: Colors.green[800]!,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green[900]!.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    'Welcome Back ${widget.userName} 🧑‍🌾',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[900],
                      shadows: [
                        Shadow(
                          color: Colors.white.withOpacity(0.5),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Auto-scrolling gallery
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: AutoScrollingGallery(
                    imageUrls: const [
                      'https://i.pinimg.com/736x/6a/00/41/6a0041d0e1d980a8b0a9d2dd0cacb2c1.jpg',
                      'https://i.pinimg.com/736x/e9/f1/f3/e9f1f306a53c78166f85ae8315db921c.jpg',
                      'https://i.pinimg.com/1200x/bb/85/56/bb8556769289d7ca297634aa9d8ffda0.jpg',
                      'https://i.pinimg.com/736x/c2/41/41/c24141162ee2853351e012cd0689bb93.jpg',
                      'https://i.pinimg.com/1200x/ca/b3/18/cab318dcb2aa78393cde56dc5986ee7f.jpg',
                      'https://i.pinimg.com/736x/eb/24/b9/eb24b91c97f40e4ab8c180ee9f4cab9c.jpg',
                    ].map((url) => 'https://africulture.vercel.app/api/proxy?url=${Uri.encodeComponent(url)}').toList(),
                    captions: const [
                      "Real time weather",
                      "Modern irrigation systems",
                      "Modern Market for farmers",
                      "Vehicle Hire and Delivery",
                      "Smart Farming",
                      "Notifications and Alerts on Farming News"
                    ],
                    isPausable: true,
                    borderRadius: 10,
                    padding: EdgeInsets.zero,
                  ),
                ),
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
                _buildRecommendations(),
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
                      imagePath: 'assets/icon_s/weather.jpg',
                      title: "Weather",
                      destination: WeatherPage(),
                    ),
                    const FeatureCard(
                      imagePath: 'assets/icon_s/market.jpg',
                      title: "Market",
                      destination: AgriCommerceApp(),
                    ),
                    const FeatureCard(
                      imagePath: 'assets/icon_s/news.jpg',
                      title: "News",
                      destination: NewsPage(),
                    ),
                    const FeatureCard(
                      imagePath: 'assets/icon_s/forum.jpg',
                      title: "Community",
                      destination: ForumPage(),
                    ),
                    FeatureCard(
                      imagePath: 'assets/icon_s/hire.jpg',
                      title: "Transport",
                      destination: TransportHirePage(),
                    ),
                    const FeatureCard(
                      imagePath: 'assets/icon_s/iot.jpg',
                      title: "IoT Devices",
                      destination: DashboardPage(),
                    ),
                    FeatureCard(
                      imagePath: 'assets/icon_s/wallet.jpg',
                      title: "Pest Alert",
                      destination: ForumPage(),
                    ),
                    FeatureCard(
                      imagePath: 'assets/icon_s/wallet.jpg',
                      title: "Farm Wallet",
                      destination: ForumPage(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (showPopupBubble)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Text("Tap here for AI help!"),
                  ),
                FloatingActionButton(
                  backgroundColor: Colors.greenAccent,
                  onPressed: () => showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (BuildContext context) => const AIAssistantPopup(),
                  ),
                  child: const Icon(Icons.smart_toy_outlined),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendations() {
    final recommendations = [
      {
        'title': "Crop Rotation",
        'icon': Icons.grass,
        'subtitle': "Rotate maize with beans to improve soil health."
      },
      {
        'title': "Market Trends",
        'icon': Icons.trending_up,
        'subtitle': "Cassava prices are up 15% this month."
      },
      {
        'title': "Grants",
        'icon': Icons.attach_money,
        'subtitle': "Apply for climate-smart farming grants."
      },
    ];

    return RecommendationsList(
      recommendations: recommendations,
      iconColor: const Color(0xFF2E7D32),
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
      height: 200,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2196F3), Color(0xFF4CAF50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
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
                _iconInfo(WeatherIcons.strong_wind, "${weatherData['wind']['speed']} km/h"),
                _iconInfo(WeatherIcons.humidity, "${weatherData['main']['humidity']}%"),
                _iconInfo(WeatherIcons.barometer, "${weatherData['main']['pressure']} hPa"),
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
  final String imagePath;
  final String title;
  final Widget destination;

  const FeatureCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.destination,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      color: const Color(0xFFE8F5E9),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        ),
        borderRadius: BorderRadius.circular(16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                color: Colors.black54,
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
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