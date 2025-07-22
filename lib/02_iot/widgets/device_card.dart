import 'package:flutter/material.dart';

class DeviceCard extends StatelessWidget {
  final String deviceName;
  final String imageUrl;
  final bool isOn;
  final double value;
  final ValueChanged<bool> onToggle;
  final ValueChanged<double> onSliderChanged;

  const DeviceCard({
    super.key,
    required this.deviceName,
    required this.imageUrl,
    required this.isOn,
    required this.value,
    required this.onToggle,
    required this.onSliderChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 100),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              deviceName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SwitchListTile(
              title: const Text("Power"),
              value: isOn,
              onChanged: onToggle,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Intensity"),
                Expanded(
                  child: Slider(
                    value: value,
                    min: 0,
                    max: 100,
                    divisions: 10,
                    label: "${value.toInt()}%",
                    onChanged: onSliderChanged,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
