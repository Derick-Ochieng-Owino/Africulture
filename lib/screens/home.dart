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
      backgroundColor: const Color(0xFFFFFFFF),
      drawer: username.isNotEmpty
          ? CustomDrawer(
        userName: username,
        userEmail: userEmail,
        profileImageUrl: profileImageurl,
      )
          : null, // or show a loading drawer or empty

      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF2E7D32), // Dark Green
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
          SingleChildScrollView(
            controller: widget.scrollController,
            padding: const EdgeInsets.only(bottom: 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.lightBlue[50], // Light blue background
                    border: Border.all(
                      color: Colors.white, // Border color
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12), // Rounded corners
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Welcome Back ${widget.userName} 🧑‍🌾',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
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
                    FeatureCard(
                      icon: Icons.bug_report,
                      title: "Pest Alert",
                      destination: ForumPage(), // Replace with PestPage
                    ),
                    FeatureCard(
                      icon: Icons.attach_money,
                      title: "Loans",
                      destination: MarketPage(), // Replace with FinancialPage
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
    return SizedBox(
      height: 150,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _recommendationCard("Crop Rotation", Icons.grass, "Rotate maize with beans to improve soil health."),
          _recommendationCard("Market Trends", Icons.trending_up, "Cassava prices are up 15% this month."),
          _recommendationCard("Grants", Icons.attach_money, "Apply for climate-smart farming grants."),
        ],
      ),
    );
  }

  Widget _recommendationCard(String title, IconData icon, String subtitle) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(right: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF2E7D32), size: 32),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 12)),
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
      height: 180,
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
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WeatherPage()),
                ),
                child: const Text(
                  "7-Day Forecast",
                  style: TextStyle(color: Colors.white),
                ),
              ),
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
      color: const Color(0xFFE8F5E9), // Light Green
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
              Icon(icon, size: 36, color: const Color(0xFF2E7D32)), // Dark Green
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF212121),
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