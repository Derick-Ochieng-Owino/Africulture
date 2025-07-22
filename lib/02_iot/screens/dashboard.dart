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

  @override
  void initState() {
    super.initState();
    initMQTT();
  }

  void initMQTT() async {
    final success = await iot.connect();
    if (success) {
      iot.controlDevice("pump", "on");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Africulture Dashboard")),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            iot.controlDevice("pump", "off");
          },
          child: const Text("Turn Off Pump"),
        ),
      ),
    );
  }
}

class IoTDevicesPage extends StatefulWidget {
  const IoTDevicesPage({super.key});

  @override
  State<IoTDevicesPage> createState() => _IoTDevicesPageState();
}

class _IoTDevicesPageState extends State<IoTDevicesPage> {
  final iot = IoTService(); // IoT control instance

  List<Map<String, dynamic>> devices = [
    {
      'name': 'Irrigation Pump',
      'topic': 'pump',
      'image': 'assets/back6.jpg',
      'isOn': false,
      'value': 50.0,
    },
    {
      'name': 'Greenhouse Fan',
      'topic': 'fan',
      'image': 'https://images.unsplash.com/photo-1616627988472-8fc12788a97a',
      'isOn': true,
      'value': 75.0,
    },
    {
      'name': 'Soil Moisture Sensor',
      'topic': 'soil_sensor',
      'image': 'https://images.unsplash.com/photo-1603791440384-56cd371ee9a7',
      'isOn': true,
      'value': 40.0,
    },
  ];

  @override
  void initState() {
    super.initState();
    iot.connect(); // Optionally await or listen to state
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Farm IoT Devices')),
      body: ListView.builder(
        itemCount: devices.length,
        itemBuilder: (context, index) {
          final device = devices[index];
          return DeviceCard(
            deviceName: device['name'],
            imageUrl: device['image'],
            isOn: device['isOn'],
            value: device['value'],
            onToggle: (bool newValue) {
              setState(() {
                devices[index]['isOn'] = newValue;
              });
              iot.controlDevice(device['topic'], newValue ? "on" : "off");
            },
            onSliderChanged: (double newValue) {
              setState(() {
                devices[index]['value'] = newValue;
              });
              iot.controlDevice(device['topic'], newValue.toInt().toString());
            },
          );
        },
      ),
    );
  }
}
