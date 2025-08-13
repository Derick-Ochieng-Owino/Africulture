import 'package:africulture/01_bank/bank_home.dart';
import 'package:africulture/02_iot/screens/dashboard.dart';
import 'package:africulture/08_community/forum_page.dart';
import 'package:africulture/05_hire/hire_page.dart';
import 'package:africulture/04_news/news_screen.dart';
import 'package:africulture/09_profile/user_profile_modal.dart';
import 'package:africulture/11_home/widgets/weather_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:africulture/03_weather/weather_page.dart';
import 'package:flutter/rendering.dart';
import '../../06_market/screens/agricommerce.dart';
import '../widgets/gallery_widget.dart';
import '../../03_weather/weather_service.dart';
import '../service/location_service.dart';
import 'package:africulture/09_profile/profile.dart';
import '../../07_AIassistant/ai_assistant_popup.dart';
import '../../13_Notifications/notifications_screen.dart';
import 'package:africulture/09_profile/custom_drawer.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

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
  final GlobalKey homeKey = GlobalKey();
  final GlobalKey appBarKey = GlobalKey();
  final GlobalKey aiAssistantKey = GlobalKey();
  final List<GlobalKey> bottomNavKeys = List.generate(3, (_) => GlobalKey());
  final List<GlobalKey> quickActionKeys = List.generate(8, (_) => GlobalKey());
  final GlobalKey appBarNotificationKey = GlobalKey();
  final GlobalKey appBarSearchKey = GlobalKey();
  late TutorialCoachMark tutorialCoachMark;
  int myIndex = 0;
  late PageController _pageController;
  late ScrollController _scrollController;
  bool _isBottomBarVisible = false;
  late AnimationController _fabAnimationController;

  String username = '';
  String userEmail = '';
  String profileImageUrl = '';
  String userLocation = 'Loading...';

  final List<String> quickActionDescriptions = [
    "Check For Weather Updates",
    "Visit Farmers Market From Here.",
    "Read Latest Agricultural News",
    "Post In Community With Many Other Farmers.",
    "Hire A Drive To Transport Your Feed",
    "Manage IoT Devices",
    "Banking Solution For You",
    "Get Help From Experts",
  ];

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
        userLocation = data['village'] ?? 'Unknown location';
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pageController.jumpToPage(0);
      safeShowTutorial();
    });
  }

  void scrollToQuickAction(int index) {
    if (_scrollController.hasClients) {
      RenderBox? box =
          quickActionKeys[index].currentContext?.findRenderObject()
              as RenderBox?;
      if (box != null) {
        double y = box.localToGlobal(Offset.zero).dy + _scrollController.offset;
        _scrollController.animateTo(
          y - 100, // offset to position nicely
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void safeShowTutorial() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      scrollToQuickAction(0);

      tutorialCoachMark = TutorialCoachMark(
        targets: _createTargets(),
        colorShadow: Colors.black.withOpacity(0.7),
        paddingFocus: 10,
        opacityShadow: 0.7,
      );
      tutorialCoachMark.show(context: context);
    });
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

  List<TargetFocus> _createTargets() {
    return [
      TargetFocus(
        identify: "Africulture",
        keyTarget: homeKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: const Text(
              "This is your Home Dashboard with quick access to features.",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "ai",
        keyTarget: aiAssistantKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: const Text(
              "Use the AI Assistant for instant help. You can upload crop images for diagnosis.",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
      // Quick action icons
      for (int i = 0; i < quickActionKeys.length; i++)
        TargetFocus(
          identify: "quick_action_$i",
          keyTarget: quickActionKeys[i],
          contents: [
            TargetContent(
              align: ContentAlign.top,
              child: Text(
                quickActionDescriptions[i],
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ],
        ),
      // Bottom Navigation
      for (int i = 0; i < bottomNavKeys.length; i++)
        TargetFocus(
          identify: "bottom_nav_$i",
          keyTarget: bottomNavKeys[i],
          contents: [
            TargetContent(
              align: ContentAlign.top,
              child: Text(
                "Bottom Navigation ${i + 1}",
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      // App bar notifications
      TargetFocus(
        identify: "notifications",
        keyTarget: appBarNotificationKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: const Text(
              "Check notifications here.",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "search",
        keyTarget: appBarSearchKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: const Text(
              "Search posts and products here.",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(
        userName: username,
        userEmail: userEmail,
        profileImageUrl: profileImageUrl,
        location: userLocation,
      ),
      appBar: AppBar(
        key: appBarKey,
        backgroundColor: Colors.teal,
        iconTheme: const IconThemeData(color: Colors.white),
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
            Image.asset('assets/app_logo.png', height: 30, color: Colors.white),
            const SizedBox(width: 10),
            const Text(
              'Africulture',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
          ],
        ),
        actions: [
          IconButton(
            key: appBarNotificationKey,
            icon: const Icon(Icons.notifications_none),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotificationPage()),
            ),
          ),
          IconButton(
            key: appBarSearchKey,
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implement search functionality
            },
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          return PageView(
            key: homeKey,
            controller: _pageController,
            onPageChanged: (index) => safeSetState(() => myIndex = index),
            children: [
              KeyedSubtree(
                child: HomePageContent(
                  scrollController: _scrollController,
                  userName: username,
                  location: userLocation,
                  quickActionKeys: quickActionKeys,
                ),
              ),
              const NewsPage(showAppBar: false),
              FirebaseAuth.instance.currentUser != null
                  ? ProfilePage(
                      user: FirebaseAuth.instance.currentUser!,
                      showAppBar: false,
                    )
                  : const Center(child: Text("Please login to view profile")),
            ],
          );
        },
      ),
      bottomNavigationBar: Builder(
        builder: (context) {
          return BottomNavigationBar(
            backgroundColor: Colors.white,
            currentIndex: myIndex,
            selectedItemColor: Colors.teal,
            unselectedItemColor: Colors.grey.shade600,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
            onTap: onTabTapped,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined, key: bottomNavKeys[0]),
                activeIcon: Icon(Icons.home, key: bottomNavKeys[0]),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.article_outlined, key: bottomNavKeys[1]),
                activeIcon: const Icon(Icons.article),
                label: 'News',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline, key: bottomNavKeys[2]),
                activeIcon: const Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          );
        },
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimationController,
        child: FloatingActionButton(
          key: aiAssistantKey,
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
  final List<GlobalKey> quickActionKeys;

  const HomePageContent({
    super.key,
    required this.scrollController,
    required this.userName,
    required this.location,
    required this.quickActionKeys,
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
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

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
              WeatherCard(
                weatherData: _weatherData,
                isLoading: _isLoading,
                error: _error,
              ),
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
            color: Colors.teal.withOpacity(0.2),
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
              key: widget.quickActionKeys[0],
              icon: Icons.cloud,
              label: 'Weather',
              color: Colors.lightBlue,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WeatherPage()),
              ),
            ),
            _buildQuickAction(
              key: widget.quickActionKeys[1],
              icon: Icons.shopping_cart,
              label: 'Market',
              color: Colors.green,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AgriCommerceApp()),
              ),
            ),
            _buildQuickAction(
              key: widget.quickActionKeys[2],
              icon: Icons.newspaper,
              label: 'News',
              color: Colors.deepOrange,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NewsPage()),
              ),
            ),
            _buildQuickAction(
              key: widget.quickActionKeys[3],
              icon: Icons.people,
              label: 'Community',
              color: Colors.purple,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ForumPage()),
              ),
            ),
            _buildQuickAction(
              key: widget.quickActionKeys[4],
              icon: Icons.local_shipping,
              label: 'Transport',
              color: Colors.teal,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TransportHirePage()),
              ),
            ),
            _buildQuickAction(
              key: widget.quickActionKeys[5],
              icon: Icons.devices,
              label: 'IoT',
              color: Colors.indigo,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const IOTDashboardPage(),
                ),
              ),
            ),
            _buildQuickAction(
              key: widget.quickActionKeys[6],
              icon: Icons.account_balance_wallet,
              label: 'Wallet',
              color: Colors.amber,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BankScreen()),
              ),
            ),
            _buildQuickAction(
              key: widget.quickActionKeys[7],
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
    Key? key,
  }) {
    return InkWell(
      key: key,
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
