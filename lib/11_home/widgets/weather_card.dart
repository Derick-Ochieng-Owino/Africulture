import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_icons/weather_icons.dart';
import '../../03_weather/weather_page.dart';

class WeatherCard extends StatelessWidget {
  final Map<String, dynamic>? weatherData;
  final bool isLoading;
  final String error;

  const WeatherCard({
    super.key,
    required this.weatherData,
    required this.isLoading,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Show loader
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Show error
    if (error.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(error, style: TextStyle(color: Colors.red)),
      );
    }

    // No data
    if (weatherData == null) return const SizedBox();

    // Extract weather values
    final temp = weatherData!['main']['temp'].toStringAsFixed(1);
    final condition = weatherData!['weather'][0]['main'];
    final humidity = weatherData!['main']['humidity'];
    final windSpeed = weatherData!['wind']['speed'];
    final cityName = weatherData!['name'];

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
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Weather Today',
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(color: theme.primaryColor),
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

                // Weather Content
                _buildWeatherContent(
                  theme,
                  temp,
                  condition,
                  humidity,
                  windSpeed,
                  cityName,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherContent(ThemeData theme, String temp, String condition,
      dynamic humidity, dynamic windSpeed, String cityName) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Weather Icon + Temp
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

            // City Name
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  cityName,
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

        // Stats Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildWeatherStat('Humidity', '$humidity%', Icons.opacity),
            _buildWeatherStat('Wind', '${windSpeed}km/h', WeatherIcons.strong_wind),
            _buildWeatherStat(
              'Pressure',
              '${weatherData!['main']['pressure']}hPa',
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

  // Map weather conditions to icons
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
}
