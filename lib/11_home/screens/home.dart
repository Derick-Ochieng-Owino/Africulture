import 'package:africulture/01_bank/bank_home.dart';
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
import '../../06_market/screens/agricommerce.dart';
import '../widgets/gallery_widget.dart';
import '/03_weather/services/weather_service.dart';
import '../service/location_service.dart';
import 'package:africulture/09_profile/profile.dart';
import '/07_AIassistant/widgets/ai_assistant_popup.dart';
import '/11_home/screens/notifications_screen.dart';
import 'package:africulture/09_profile/custom_drawer.dart';
import 'package:weather_icons/weather_icons.dart';
import 'package:intl/intl.dart';

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
        primarySwatch: createMaterialColor(const Color(0xFF2E7D32)),
        scaffoldBackgroundColor: const Color(0xFFF9F9F9).withOpacity(0.4),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(8),
        ),
        textTheme: const TextTheme(
          headlineSmall: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          bodyMedium: TextStyle(fontSize: 14, color: Colors.black87),
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  Map<int, Color> swatch = {};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  for (var strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }
  return MaterialColor(color.value, swatch);
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

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  int myIndex = 0;
  late PageController _pageController;
  late ScrollController _scrollController;
  bool _isBottomBarVisible = true;
  late AnimationController _fabAnimationController;

  String username = '';
  String userEmail = '';
  String profileImageUrl = '';
  String userLocation = 'Loading...';

  Future<void> getUserInfo(String uid) async {
    final doc = await FirebaseFirestore.instance
        .collection('farmers')
        .doc(uid)
        .get();
    final data = doc.data();
    if (data != null) {
      setState(() {
        username = data['name'] ?? '';
        userEmail = data['email'] ?? '';
        profileImageUrl = data['photoUrl'] ?? '';
        userLocation = data['location'] ?? 'Unknown location';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      getUserInfo(currentUser.uid);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        checkProfileAndShowModal(context, currentUser.uid);
      });
    }

    _fabAnimationController.forward();
  }

  void _scrollListener() {
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (_isBottomBarVisible) {
        setState(() => _isBottomBarVisible = false);
        _fabAnimationController.reverse();
      }
    } else if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (!_isBottomBarVisible) {
        setState(() => _isBottomBarVisible = true);
        _fabAnimationController.forward();
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    _fabAnimationController.dispose();
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
      backgroundColor: const Color(0xFFF5F9F3),
      drawer: username.isNotEmpty
          ? CustomDrawer(
              userName: username,
              userEmail: userEmail,
              profileImageUrl: profileImageUrl,
              location: userLocation,
            )
          : null,
      appBar: AppBar(
        backgroundColor: Color(0xFF2E7D32),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/app_logo.png',
              height: 30,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            const Text(
              'Africulture',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotificationPage()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implement search functionality
            },
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => myIndex = index),
        children: [
          HomePageContent(
            scrollController: _scrollController,
            userName: username,
            location: userLocation,
          ),
          const NewsPage(),
          FirebaseAuth.instance.currentUser != null
              ? ProfilePage(user: FirebaseAuth.instance.currentUser!)
              : const Center(child: Text("Please login to view profile")),
        ],
      ),
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: _isBottomBarVisible ? 70 : 0,
        child: Wrap(
          children: [
            BottomNavigationBar(
              backgroundColor: Colors.white,
              currentIndex: myIndex,
              selectedItemColor: const Color(0xFF2E7D32),
              unselectedItemColor: Colors.grey.shade600,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
              type: BottomNavigationBarType.fixed,
              onTap: onTabTapped,
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.home_outlined),
                  activeIcon: const Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.article_outlined),
                  activeIcon: const Icon(Icons.article),
                  label: 'News',
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.person_outline),
                  activeIcon: const Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimationController,
        child: FloatingActionButton(
          backgroundColor: const Color(0xFF4CAF50),
          onPressed: () => showDialog(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext context) => const AIAssistantPopup(),
          ),
          child: const Icon(Icons.assistant, color: Colors.white),
        ),
      ),
    );
  }
}

class HomePageContent extends StatefulWidget {
  final ScrollController scrollController;
  final String userName;
  final String location;

  const HomePageContent({
    super.key,
    required this.scrollController,
    required this.userName,
    required this.location,
  });

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  Map<String, dynamic>? _weatherData;
  bool _isLoading = true;
  String _error = '';
  bool showPopupBubble = true;
  DateTime? _lastPopupTime;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
    _lastPopupTime = DateTime.now();
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

  void _showGreeting() {
    final now = DateTime.now();
    if (_lastPopupTime == null ||
        now.difference(_lastPopupTime!) > const Duration(hours: 1)) {
      setState(() {
        showPopupBubble = true;
        _lastPopupTime = now;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeNow = DateTime.now();
    final hour = timeNow.hour;
    String greeting = 'Good day';

    if (hour < 12) {
      greeting = 'Good morning';
    } else if (hour < 17) {
      greeting = 'Good afternoon';
    } else {
      greeting = 'Good evening';
    }

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _fetchWeather,
        color: theme.primaryColor,
        child: SingleChildScrollView(
          controller: widget.scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeCard(theme, greeting),
              _buildWeatherCard(theme),
              _buildQuickActionsGrid(),
              _buildRecommendationsSection(theme),
              _buildGallerySection(theme),
              _buildMarketTrendsSection(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(ThemeData theme, String greeting) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$greeting, ${widget.userName.split(' ').first}',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.location,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Ready to make the most of your farming today?',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.notifications_active,
                  color: Colors.white,
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationPage(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherCard(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const WeatherPage()),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Weather Today',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.primaryColor,
                      ),
                    ),
                    Text(
                      DateFormat('EEEE, MMM d').format(DateTime.now()),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _error.isNotEmpty
                    ? Text(_error)
                    : _buildWeatherContent(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherContent(ThemeData theme) {
    final temp = _weatherData!['main']['temp'].toStringAsFixed(1);
    final condition = _weatherData!['weather'][0]['main'];
    final humidity = _weatherData!['main']['humidity'];
    final windSpeed = _weatherData!['wind']['speed'];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                BoxedIcon(
                  getWeatherIcon(condition),
                  color: theme.primaryColor,
                  size: 48,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$temp°C',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      condition,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _weatherData!['name'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Divider(color: Colors.grey.shade300),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildWeatherStat('Humidity', '$humidity%', Icons.opacity),
            _buildWeatherStat(
              'Wind',
              '${windSpeed}km/h',
              WeatherIcons.strong_wind,
            ),
            _buildWeatherStat(
              'Pressure',
              '${_weatherData!['main']['pressure']}hPa',
              WeatherIcons.barometer,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeatherStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey.shade600, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildQuickActionsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
          child: Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          children: [
            _buildQuickAction(
              icon: Icons.cloud,
              label: 'Weather',
              color: Colors.lightBlue,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WeatherPage()),
              ),
            ),
            _buildQuickAction(
              icon: Icons.shopping_cart,
              label: 'Market',
              color: Colors.green,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AgriCommerceApp()),
              ),
            ),
            _buildQuickAction(
              icon: Icons.newspaper,
              label: 'News',
              color: Colors.deepOrange,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NewsPage()),
              ),
            ),
            _buildQuickAction(
              icon: Icons.people,
              label: 'Community',
              color: Colors.purple,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ForumPage()),
              ),
            ),
            _buildQuickAction(
              icon: Icons.local_shipping,
              label: 'Transport',
              color: Colors.teal,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TransportHirePage()),
              ),
            ),
            _buildQuickAction(
              icon: Icons.devices,
              label: 'IoT',
              color: Colors.indigo,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DashboardPage()),
              ),
            ),
            _buildQuickAction(
              icon: Icons.account_balance_wallet,
              label: 'Wallet',
              color: Colors.amber,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BankScreen()),
              ),
            ),
            _buildQuickAction(
              icon: Icons.help,
              label: 'Help',
              color: Colors.redAccent,
              onTap: () => showDialog(
                context: context,
                builder: (context) => const AIAssistantPopup(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 24, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
          child: Text(
            'Recommendations',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.primaryColor,
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildRecommendationCard(
                icon: Icons.rotate_right,
                title: 'Crop Rotation',
                description: 'Rotate maize with beans to improve soil health',
                color: Colors.orange.shade100,
                iconColor: Colors.orange,
              ),
              _buildRecommendationCard(
                icon: Icons.trending_up,
                title: 'Market Trends',
                description: 'Cassava prices are up 15% this month',
                color: Colors.green.shade100,
                iconColor: Colors.green,
              ),
              _buildRecommendationCard(
                icon: Icons.attach_money,
                title: 'Grants',
                description: 'Apply for climate-smart farming grants',
                color: Colors.blue.shade100,
                iconColor: Colors.blue,
              ),
              _buildRecommendationCard(
                icon: Icons.water_drop,
                title: 'Irrigation',
                description: 'Water your crops early morning for best results',
                color: Colors.blue.shade100,
                iconColor: Colors.blue.shade700,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required Color iconColor,
  }) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGallerySection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
          child: Text(
            'Featured Content',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.primaryColor,
            ),
          ),
        ),
        AutoScrollingGallery(
          imageUrls:
              const [
                    'https://i.pinimg.com/736x/6a/00/41/6a0041d0e1d980a8b0a9d2dd0cacb2c1.jpg',
                    'https://i.pinimg.com/736x/e9/f1/f3/e9f1f306a53c78166f85ae8315db921c.jpg',
                    'https://i.pinimg.com/1200x/bb/85/56/bb8556769289d7ca297634aa9d8ffda0.jpg',
                    'https://i.pinimg.com/736x/c2/41/41/c24141162ee2853351e012cd0689bb93.jpg',
                    'https://i.pinimg.com/1200x/ca/b3/18/cab318dcb2aa78393cde56dc5986ee7f.jpg',
                    'https://i.pinimg.com/736x/eb/24/b9/eb24b91c97f40e4ab8c180ee9f4cab9c.jpg',
                  ]
                  .map(
                    (url) =>
                        'https://imageproxy-ggs6evtqha-uc.a.run.app?url=${Uri.encodeComponent(url)}',
                  )
                  .toList(),
          captions: const [
            "Real time weather",
            "Modern irrigation systems",
            "Modern Market for farmers",
            "Vehicle Hire and Delivery",
            "Smart Farming",
            "Notifications and Alerts on Farming News",
          ],
          isPausable: true,
          borderRadius: 12,
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ],
    );
  }

  Widget _buildMarketTrendsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
          child: Text(
            'Market Trends',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.primaryColor,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildMarketTrendItem('Maize', '+12%', Colors.green),
              const Divider(),
              _buildMarketTrendItem('Beans', '+5%', Colors.green),
              const Divider(),
              _buildMarketTrendItem('Rice', '-3%', Colors.red),
              const Divider(),
              _buildMarketTrendItem('Tomatoes', '+8%', Colors.green),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AgriCommerceApp()),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('View Full Market Prices'),
          ),
        ),
      ],
    );
  }

  Widget _buildMarketTrendItem(String crop, String change, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            crop,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Text(
            change,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
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
      elevation: 2,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        ),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Image.asset(imagePath, height: 120, fit: BoxFit.cover),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(12),
                ),
              ),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
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
