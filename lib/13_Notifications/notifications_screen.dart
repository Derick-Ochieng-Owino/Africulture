import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import '../main.dart';
import 'notification_model.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<NotificationItem> _notifications = [];
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
  }

  // Demo notification (optional, for testing)
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

  // Notification Preferences
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

  // Location filtering
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
  }

  // Load simulated notifications
  Future<void> _loadNotifications() async {
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _notifications = [
        NotificationItem(
          id: '1',
          title: 'Heavy Rainfall Alert',
          body: '50mm rain expected tomorrow in Nairobi County',
          type: 'weather',
          time: DateTime.now().subtract(const Duration(minutes: 30)),
          read: false,
          community: true,
        ),
        NotificationItem(
          id: '2',
          title: 'Maize Price Surge',
          body: 'Prices up 15% at Eldoret market this week',
          type: 'market',
          time: DateTime.now().subtract(const Duration(hours: 2)),
          read: true,
          community: false,
        ),
        NotificationItem(
          id: '3',
          title: 'New Forum Discussion',
          body: '10 farmers discussing drought-resistant crops',
          type: 'community',
          time: DateTime.now().subtract(const Duration(days: 1)),
          read: true,
          community: true,
        ),
        NotificationItem(
          id: '4',
          title: 'Equipment Rental Available',
          body: 'Tractors available in Kiambu at \$50/day',
          type: 'equipment',
          time: DateTime.now().subtract(const Duration(days: 2)),
          read: false,
          community: true,
        ),
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
                  return buildNotificationCard(filteredNotifications[index]);
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _sendCommunityNotification,
        tooltip: 'Create community alert',
        child: const Icon(Icons.add_alert),
      ),
    );
  }

  List<NotificationItem> _applyAllFilters() {
    return _notifications.where((notification) {
      if (_showCommunityOnly && !notification.community) return false;
      if (_selectedFilter != 'all' && notification.type != _selectedFilter)
        return false;
      if (_selectedPreferences.isNotEmpty &&
          !_selectedPreferences.contains(notification.type)) return false;
      return true;
    }).toList();
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

  Widget buildNotificationCard(NotificationItem item) {
    Color cardColor;
    Icon icon;

    switch (item.type) {
      case 'community':
        cardColor = Colors.orange.shade50;
        icon = const Icon(Icons.people, color: Colors.orange);
        break;
      case 'weather':
        cardColor = Colors.blue.shade50;
        icon = const Icon(Icons.cloud, color: Colors.blue);
        break;
      case 'market':
        cardColor = Colors.green.shade50;
        icon = const Icon(Icons.attach_money, color: Colors.green);
        break;
      case 'equipment':
        cardColor = Colors.brown.shade50;
        icon = const Icon(Icons.agriculture, color: Colors.brown);
        break;
      case 'pests':
        cardColor = Colors.red.shade50;
        icon = const Icon(Icons.bug_report, color: Colors.red);
        break;
      default:
        cardColor = Colors.grey.shade200;
        icon = const Icon(Icons.notifications, color: Colors.grey);
    }

    return Card(
      color: cardColor,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  icon,
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    DateFormat('MMM d, h:mm a').format(item.time),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(item.body),
              if (item.imageUrl != null) ...[
                const SizedBox(height: 6),
                Image.network(item.imageUrl!),
              ],
            ],
          ),
        ),
      ),
    );
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

// Notification Preferences Screen stays the same
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
