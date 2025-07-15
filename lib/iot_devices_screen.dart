import 'package:flutter/material.dart';

class IoTDevicesScreen extends StatefulWidget {
  const IoTDevicesScreen({super.key});

  @override
  State<IoTDevicesScreen> createState() => _IoTDevicesScreenState();
}

class _IoTDevicesScreenState extends State<IoTDevicesScreen> {
  bool irrigationOn = false;
  double temperature = 25.0;
  bool leavesOpen = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('IoT Device Control'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SwitchListTile(
              title: Text('Irrigation System'),
              value: irrigationOn,
              onChanged: (val) {
                setState(() {
                  irrigationOn = val;
                });
              },
            ),
            SizedBox(height: 20),
            Text('Temperature Control: ${temperature.toStringAsFixed(1)}°C'),
            Slider(
              min: 10,
              max: 40,
              value: temperature,
              onChanged: (val) {
                setState(() {
                  temperature = val;
                });
              },
            ),
            SizedBox(height: 20),
            SwitchListTile(
              title: Text('Open Leaves'),
              value: leavesOpen,
              onChanged: (val) {
                setState(() {
                  leavesOpen = val;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
