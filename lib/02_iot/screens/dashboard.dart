import 'package:flutter/material.dart';
import '../widgets/device_card.dart';
import '/02_iot/services/iot_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final iot = IoTService();
  int _currentIndex = 0;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _initMQTT();
  }

  Future<void> _initMQTT() async {
    final success = await iot.connect();
    setState(() {
      _isConnected = success;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Farm Control Dashboard"),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green[700]!, Colors.green[400]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Icon(
              _isConnected ? Icons.cloud_done : Icons.cloud_off,
              color: _isConnected ? Colors.white : Colors.amber,
            ),
          ),
        ],
      ),
      body: _buildPageContent(),
      bottomNavigationBar: _buildBottomNavBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new device functionality
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildPageContent() {
    switch (_currentIndex) {
      case 0:
        return _buildDashboardView();
      case 1:
        return const IoTDevicesPage();
      case 2:
        return _buildAnalyticsView();
      default:
        return const Center(child: Text('Page not found'));
    }
  }

  Widget _buildDashboardView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusCard(),
          const SizedBox(height: 20),
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.green[800],
            ),
          ),
          const SizedBox(height: 10),
          _buildQuickActions(),
          const SizedBox(height: 20),
          Text(
            'Device Summary',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.green[800],
            ),
          ),
          const SizedBox(height: 10),
          _buildDeviceSummary(),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green[600]!, Colors.green[400]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Farm Status',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _isConnected ? Colors.green[800] : Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _isConnected ? 'Connected' : 'Disconnected',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(Icons.devices, '5', 'Devices'),
                _buildStatItem(Icons.water_drop, '78%', 'Soil Moisture'),
                _buildStatItem(Icons.thermostat, '24°C', 'Temperature'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }

  Widget _buildQuickActions() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildActionButton('Irrigation', Icons.opacity, Colors.blue),
        _buildActionButton('Ventilation', Icons.air, Colors.teal),
        _buildActionButton('Lighting', Icons.lightbulb, Colors.amber),
        _buildActionButton('Security', Icons.security, Colors.red),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {

        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceSummary() {
    return Column(
      children: [
        _buildSummaryItem('Irrigation Pump', '65%', Colors.blue),
        _buildSummaryItem('Greenhouse Fan', 'On', Colors.teal),
        _buildSummaryItem('Soil Sensor', 'Active', Colors.green),
        _buildSummaryItem('Weather Station', '24°C', Colors.orange),
      ],
    );
  }

  Widget _buildSummaryItem(String name, String status, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(_getDeviceIcon(name), color: color),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: Chip(
          label: Text(status, style: TextStyle(color: Colors.white)),
          backgroundColor: color,
        ),
        onTap: () {
          // Navigate to device details
        },
      ),
    );
  }

  IconData _getDeviceIcon(String name) {
    if (name.contains('Pump')) return Icons.opacity;
    if (name.contains('Fan')) return Icons.air;
    if (name.contains('Sensor')) return Icons.sensors;
    if (name.contains('Station')) return Icons.device_thermostat;
    return Icons.device_unknown;
  }

  Widget _buildAnalyticsView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics, size: 64, color: Colors.green),
          const SizedBox(height: 16),
          Text(
            'Farm Analytics',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text('Coming soon...', style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
      selectedItemColor: Colors.green[800],
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.devices), label: 'Devices'),
        BottomNavigationBarItem(
          icon: Icon(Icons.analytics),
          label: 'Analytics',
        ),
      ],
    );
  }
}

class IoTDevicesPage extends StatefulWidget {
  const IoTDevicesPage({super.key});

  @override
  State<IoTDevicesPage> createState() => _IoTDevicesPageState();
}

class _IoTDevicesPageState extends State<IoTDevicesPage> {
  final iot = IoTService();
  bool _isLoading = true;

  List<Map<String, dynamic>> devices = [
    {
      'name': 'Irrigation Pump',
      'topic': 'pump',
      'image': 'https://images.unsplash.com/photo-1624397640148-949b1732bb0a',
      'isOn': false,
      'value': 50.0,
      'type': 'water',
    },
    {
      'name': 'Greenhouse Fan',
      'topic': 'fan',
      'image': 'https://images.unsplash.com/photo-1616627988472-8fc12788a97a',
      'isOn': true,
      'value': 75.0,
      'type': 'air',
    },
    {
      'name': 'Soil Moisture Sensor',
      'topic': 'soil_sensor',
      'image': 'https://images.unsplash.com/photo-1603791440384-56cd371ee9a7',
      'isOn': true,
      'value': 40.0,
      'type': 'sensor',
    },
    {
      'name': 'Grow Lights',
      'topic': 'lights',
      'image': 'https://images.unsplash.com/photo-1517999144091-3d9dca6d1e43',
      'isOn': false,
      'value': 0.0,
      'type': 'light',
    },
    {
      'name': 'Weather Station',
      'topic': 'weather',
      'image': 'https://images.unsplash.com/photo-1496442226666-8d4d0e62e6e9',
      'isOn': true,
      'value': 24.0,
      'type': 'weather',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeConnection();
  }

  Future<void> _initializeConnection() async {
    await iot.connect();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search devices...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: devices.length,
                  itemBuilder: (context, index) {
                    final device = devices[index];
                    return DeviceCard(
                      deviceName: device['name'],
                      imageUrl: device['image'],
                      isOn: device['isOn'],
                      value: device['value'],
                      deviceType: device['type'],
                      onToggle: (bool newValue) {
                        setState(() {
                          devices[index]['isOn'] = newValue;
                        });
                        iot.controlDevice(
                          device['topic'],
                          newValue ? "on" : "off",
                        );
                      },
                      onSliderChanged: (double newValue) {
                        setState(() {
                          devices[index]['value'] = newValue;
                        });
                        iot.controlDevice(
                          device['topic'],
                          newValue.toInt().toString(),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
  }
}
