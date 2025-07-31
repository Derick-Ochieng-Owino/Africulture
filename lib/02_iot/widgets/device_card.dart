import 'package:flutter/material.dart';

class DeviceCard extends StatelessWidget {
  final String deviceName;
  final String imageUrl;
  final bool isOn;
  final double value;
  final String deviceType;
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
    required this.deviceType,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = _getDeviceColor(deviceType);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16)),
                child: Image.network(
                  imageUrl,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 140,
                      color: Colors.grey[200],
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 140,
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image, size: 60),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isOn ? primaryColor : Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isOn ? 'ACTIVE' : 'OFFLINE',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      deviceName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      _getDeviceIcon(deviceType),
                      color: primaryColor,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Status',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isOn ? 'Running' : 'Stopped',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: isOn ? primaryColor : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Current Value',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${value.toInt()}%',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Power',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Switch.adaptive(
                      value: isOn,
                      onChanged: onToggle,
                      activeColor: primaryColor,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Intensity',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: primaryColor,
                    inactiveTrackColor: primaryColor.withOpacity(0.3),
                    thumbColor: primaryColor,
                    overlayColor: primaryColor.withOpacity(0.2),
                    valueIndicatorColor: primaryColor,
                  ),
                  child: Slider(
                    value: value,
                    min: 0,
                    max: 100,
                    divisions: 10,
                    label: "${value.toInt()}%",
                    onChanged: isOn ? onSliderChanged : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getDeviceColor(String type) {
    switch (type) {
      case 'water':
        return Colors.blue;
      case 'air':
        return Colors.teal;
      case 'light':
        return Colors.amber;
      case 'sensor':
        return Colors.green;
      case 'weather':
        return Colors.orange;
      default:
        return Colors.purple;
    }
  }

  IconData _getDeviceIcon(String type) {
    switch (type) {
      case 'water':
        return Icons.opacity;
      case 'air':
        return Icons.air;
      case 'light':
        return Icons.lightbulb;
      case 'sensor':
        return Icons.sensors;
      case 'weather':
        return Icons.device_thermostat;
      default:
        return Icons.device_unknown;
    }
  }
}