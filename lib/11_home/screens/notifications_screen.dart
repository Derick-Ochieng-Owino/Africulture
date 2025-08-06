import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';

// 1. PUSH NOTIFICATION SETUP
final FlutterLocalNotificationsPlugin notificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Notification channel setup
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await notificationsPlugin.initialize(initializationSettings);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FarmConnect',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const NotificationPage(),
    );
  }
}

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<Map<String, dynamic>> _notifications = [];
  bool _showCommunityOnly = false;
  String _selectedFilter = 'all';
  Position? _currentPosition;
  List<String> _selectedPreferences = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _loadPreferences();
    _getCurrentLocation();
    _configurePushNotifications();
  }

  // 1. PUSH NOTIFICATION INTEGRATION
  void _configurePushNotifications() async {
    await notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            'farm_alerts',
            'Farm Alerts',
            importance: Importance.high,
          ),
        );

    // Simulate incoming push notification
    Future.delayed(const Duration(seconds: 3), () {
      _showDemoNotification();
    });
  }

  void _showDemoNotification() {
    notificationsPlugin.show(
      0,
      'New Pest Alert!',
      'Fall armyworm detected in your region',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'farm_alerts',
          'Farm Alerts',
          importance: Importance.high,
          color: Colors.green,
        ),
      ),
    );
  }

  // 2. NOTIFICATION PREFERENCES SCREEN
  Future<void> _openPreferences() async {
    final List<String> allCategories = [
      'weather',
      'market',
      'pests',
      'equipment',
      'community',
    ];

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationPreferencesScreen(
          initialSelection: _selectedPreferences,
          allCategories: allCategories,
        ),
      ),
    );

    if (result != null) {
      setState(() => _selectedPreferences = result);
      _savePreferences();
    }
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('notification_prefs', _selectedPreferences);
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedPreferences = prefs.getStringList('notification_prefs') ?? [];
    });
  }

  // 3. LOCATION-BASED FILTERING
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    final position = await Geolocator.getCurrentPosition();
    setState(() => _currentPosition = position);
    _filterByLocation(position);
  }

  void _filterByLocation(Position position) {
    // In real app, compare with notification's geo-fence
    debugPrint(
      'Filtering for location: ${position.latitude},${position.longitude}',
    );
  }

  // NOTIFICATION DATA MANAGEMENT
  Future<void> _loadNotifications() async {
    // Simulated data - replace with API call
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _notifications = [
        {
          'id': '1',
          'title': 'Heavy Rainfall Alert',
          'body': '50mm rain expected tomorrow in Nairobi County',
          'type': 'weather',
          'priority': 'high',
          'time': DateTime.now().subtract(const Duration(minutes: 30)),
          'read': false,
          'community': true,
          'location': {'lat': -1.286389, 'lng': 36.817223, 'radius': 50},
        },
        {
          'id': '2',
          'title': 'Maize Price Surge',
          'body': 'Prices up 15% at Eldoret market this week',
          'type': 'market',
          'priority': 'medium',
          'time': DateTime.now().subtract(const Duration(hours: 2)),
          'read': true,
          'community': false,
          'location': null,
        },
        {
          'id': '3',
          'title': 'New Forum Discussion',
          'body': '10 farmers discussing drought-resistant crops',
          'type': 'community',
          'priority': 'low',
          'time': DateTime.now().subtract(const Duration(days: 1)),
          'read': true,
          'community': true,
          'location': null,
        },
        {
          'id': '4',
          'title': 'Equipment Rental Available',
          'body': 'Tractors available in Kiambu at \$50/day',
          'type': 'equipment',
          'priority': 'medium',
          'time': DateTime.now().subtract(const Duration(days: 2)),
          'read': false,
          'community': true,
          'location': {'lat': -1.1667, 'lng': 36.8333, 'radius': 30},
        },
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredNotifications = _applyAllFilters();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Farm Alerts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openPreferences,
            tooltip: 'Notification preferences',
          ),
          IconButton(
            icon: Icon(_showCommunityOnly ? Icons.group : Icons.group_off),
            onPressed: () =>
                setState(() => _showCommunityOnly = !_showCommunityOnly),
            tooltip: _showCommunityOnly
                ? 'Show all notifications'
                : 'Show community only',
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: [
                _buildFilterChip('All', 'all'),
                _buildFilterChip('Weather', 'weather'),
                _buildFilterChip('Market', 'market'),
                _buildFilterChip('Pests', 'pests'),
                _buildFilterChip('Equipment', 'equipment'),
                if (_currentPosition != null)
                  _buildFilterChip('Near Me', 'location'),
              ],
            ),
          ),
          // Notifications List
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadNotifications,
              child: filteredNotifications.isEmpty
                ? const Center(
                  child: Text(
                    'No matching notifications',
                    style: TextStyle(fontSize: 16),
                  ),
                )
                : ListView.builder(
                  itemCount: filteredNotifications.length,
                  itemBuilder: (context, index) {
                    return _buildNotificationCard(
                      filteredNotifications[index],
                      context,
                    );
                  },
                ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _sendCommunityNotification,
        child: const Icon(Icons.add_alert),
        tooltip: 'Create community alert',
      ),
    );
  }

  List<Map<String, dynamic>> _applyAllFilters() {
    return _notifications.where((notification) {
      if (_showCommunityOnly && !notification['community']) return false;

      // 2. Type filter
      if (_selectedFilter != 'all' && notification['type'] != _selectedFilter)
        return false;

      // 3. Preference filter
      if (_selectedPreferences.isNotEmpty &&
          !_selectedPreferences.contains(notification['type']))
        return false;

      // 4. Location filter
      if (_selectedFilter == 'location' &&
          _currentPosition != null &&
          notification['location'] != null) {
        return _isInRange(notification['location'], _currentPosition!);
      }

      return true;
    }).toList();
  }

  bool _isInRange(Map<String, dynamic>? location, Position userPosition) {
    if (location == null) return false;

    final distance = Geolocator.distanceBetween(
      userPosition.latitude,
      userPosition.longitude,
      location['lat'],
      location['lng'],
    );

    return distance <= location['radius'] * 1000;
  }

  Widget _buildFilterChip(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: _selectedFilter == value,
        onSelected: (_) => setState(() => _selectedFilter = value),
        backgroundColor: _selectedFilter == value
            ? Colors.green.shade200
            : Colors.grey.shade200,
      ),
    );
  }

  Widget _buildNotificationCard(
    Map<String, dynamic> notification,
    BuildContext context,
  ) {
    return Dismissible(
      key: Key(notification['id']),
      background: Container(color: Colors.red),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _deleteNotification(notification),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        color: notification['read']
            ? Theme.of(context).colorScheme.surface
            : Theme.of(context).colorScheme.surfaceVariant,
        child: InkWell(
          onTap: () => _markAsRead(notification),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _getNotificationIcon(notification['type']),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        notification['title'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: notification['read']
                              ? Colors.grey
                              : Colors.green.shade800,
                        ),
                      ),
                    ),
                    if (notification['priority'] == 'high')
                      const Icon(Icons.warning, color: Colors.red, size: 20),
                  ],
                ),
                const SizedBox(height: 8),
                Text(notification['body']),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (notification['community'])
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Community',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    const Spacer(),
                    Text(
                      DateFormat('MMM d, h:mm a').format(notification['time']),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Icon _getNotificationIcon(String type) {
    switch (type) {
      case 'weather':
        return const Icon(Icons.cloud, color: Colors.blue);
      case 'market':
        return const Icon(Icons.attach_money, color: Colors.green);
      case 'community':
        return const Icon(Icons.people, color: Colors.orange);
      case 'equipment':
        return const Icon(Icons.agriculture, color: Colors.brown);
      case 'pests':
        return const Icon(Icons.bug_report, color: Colors.red);
      default:
        return const Icon(Icons.notifications, color: Colors.grey);
    }
  }

  void _markAsRead(Map<String, dynamic> notification) {
    setState(() => notification['read'] = true);
  }

  void _deleteNotification(Map<String, dynamic> notification) {
    setState(() => _notifications.remove(notification));
  }

  void _sendCommunityNotification() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Community Alert'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Alert Title'),
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Message'),
              maxLines: 3,
            ),
            DropdownButtonFormField<String>(
              items: const [
                DropdownMenuItem(value: 'weather', child: Text('Weather')),
                DropdownMenuItem(value: 'pests', child: Text('Pest Alert')),
                DropdownMenuItem(value: 'market', child: Text('Market Tip')),
              ],
              onChanged: (_) {},
              decoration: const InputDecoration(labelText: 'Category'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // In real app, send to backend
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Alert shared with community')),
              );
              Navigator.pop(context);
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}

// 2. NOTIFICATION PREFERENCES SCREEN
class NotificationPreferencesScreen extends StatefulWidget {
  final List<String> initialSelection;
  final List<String> allCategories;

  const NotificationPreferencesScreen({
    super.key,
    required this.initialSelection,
    required this.allCategories,
  });

  @override
  State<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends State<NotificationPreferencesScreen> {
  late List<String> _selectedCategories;

  @override
  void initState() {
    super.initState();
    _selectedCategories = List.from(widget.initialSelection);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Preferences'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => Navigator.pop(context, _selectedCategories),
          ),
        ],
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Select notification types you want to receive:',
              style: TextStyle(fontSize: 16),
            ),
          ),
          ...widget.allCategories.map((category) {
            return CheckboxListTile(
              title: Text(_getCategoryName(category)),
              value: _selectedCategories.contains(category),
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    _selectedCategories.add(category);
                  } else {
                    _selectedCategories.remove(category);
                  }
                });
              },
            );
          }),
        ],
      ),
    );
  }

  String _getCategoryName(String category) {
    switch (category) {
      case 'weather':
        return 'Weather Alerts';
      case 'market':
        return 'Market Updates';
      case 'pests':
        return 'Pest/Disease Warnings';
      case 'equipment':
        return 'Equipment Rentals';
      case 'community':
        return 'Community Posts';
      default:
        return category;
    }
  }
}
