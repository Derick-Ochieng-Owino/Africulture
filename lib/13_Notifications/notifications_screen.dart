import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import '../main.dart';
import 'notification_model.dart';
import 'notification_service.dart';

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
  final _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _getCurrentLocation();

    _notificationService.getNotificationsStream().listen((data) {
      for (var notification in data) {
        if (!_notifications.any((n) => n.id == notification.id)) {
          if (notification.type == 'likes' || notification.type == 'comments' || notification.type == 'personal') {
            _showLocalNotification(notification);
          }
        }
      }

      setState(() {
        _notifications = data;
      });
    });
  }

  void _showLocalNotification(NotificationItem item) {
    notificationsPlugin.show(
      item.id.hashCode,
      item.title,
      item.body,
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

  // Preferences
  Future<void> _openPreferences() async {
    final List<String> allCategories = [
      'community',
      'likes',
      'comments',
      'admin',
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

  Future<void> _getCurrentLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) return;
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    final position = await Geolocator.getCurrentPosition();
    setState(() => _currentPosition = position);
  }

  @override
  Widget build(BuildContext context) {
    final filteredNotifications = _applyFilters();

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
                _buildFilterChip('Community', 'community'),
                _buildFilterChip('Likes', 'likes'),
                _buildFilterChip('Comments', 'comments'),
                _buildFilterChip('Admin', 'admin'),
                if (_currentPosition != null)
                  _buildFilterChip('Near Me', 'location'),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                final data = await _notificationService
                    .getNotificationsStream()
                    .first;
                setState(() => _notifications = data);
              },
              child: filteredNotifications.isEmpty
                  ? const Center(
                      child: Text(
                        'No matching notifications',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredNotifications.length,
                      itemBuilder: (context, index) =>
                          _buildNotificationCard(filteredNotifications[index]),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  List<NotificationItem> _applyFilters() {
    return _notifications.where((n) {
      if (_showCommunityOnly && !n.community) return false;
      if (_selectedFilter != 'all' && n.type != _selectedFilter) return false;
      if (_selectedPreferences.isNotEmpty &&
          !_selectedPreferences.contains(n.type))
        return false;
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

  Widget _buildNotificationCard(NotificationItem item) {
    Color cardColor;
    Icon icon;

    switch (item.type) {
      case 'community':
        cardColor = Colors.orange.shade50;
        icon = const Icon(Icons.people, color: Colors.orange);
        break;
      case 'likes':
        cardColor = Colors.pink.shade50;
        icon = const Icon(Icons.favorite, color: Colors.pink);
        break;
      case 'comments':
        cardColor = Colors.blue.shade50;
        icon = const Icon(Icons.comment, color: Colors.blue);
        break;
      case 'admin':
        cardColor = Colors.red.shade50;
        icon = const Icon(Icons.campaign, color: Colors.red);
        break;
      case 'personal':
        cardColor = Colors.green.shade50;
        icon = const Icon(Icons.notifications_active, color: Colors.green);
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
}

// Notification Preferences Screen
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
      case 'community':
        return 'Community Posts';
      case 'likes':
        return 'Post Likes';
      case 'comments':
        return 'Post Comments';
      case 'admin':
        return 'Admin Messages';
      case 'personal':
        return 'Welcome / Personal';
      default:
        return category;
    }
  }
}
