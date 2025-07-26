import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> with SingleTickerProviderStateMixin {
  final String apiKey = dotenv.env['OPENWEATHER_API_KEY'] ?? '';

  bool isLoading = true;
  String? errorMessage;

  double? temperature;
  String? description;
  String? cityName;
  String? iconCode;
  Map<String, dynamic>? currentWeatherDetails;
  List<Map<String, dynamic>> forecast = [];

  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _determinePosition().then((position) {
      _fetchWeatherByCoords(position.latitude, position.longitude);
      _refreshTimer = Timer.periodic(const Duration(minutes: 5), (_) {
        _fetchWeatherByCoords(position.latitude, position.longitude);
      });
    }).catchError((e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Could not get location: $e';
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchWeatherByCoords(double lat, double lon) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final weatherUrl = 'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&units=metric&appid=$apiKey';
    final forecastUrl = 'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&units=metric&appid=$apiKey';

    try {
      final weatherResponse = await http.get(Uri.parse(weatherUrl));
      final forecastResponse = await http.get(Uri.parse(forecastUrl));

      if (weatherResponse.statusCode == 200 && forecastResponse.statusCode == 200) {
        final weatherData = json.decode(weatherResponse.body);
        final forecastData = json.decode(forecastResponse.body);

        setState(() {
          temperature = weatherData['main']['temp'].toDouble();
          description = weatherData['weather'][0]['description'];
          cityName = weatherData['name'];
          iconCode = weatherData['weather'][0]['icon'];

          currentWeatherDetails = {
            'wind': weatherData['wind']['speed'],
            'humidity': weatherData['main']['humidity'],
            'pressure': weatherData['main']['pressure'],
            'visibility': weatherData['visibility'] / 1000,
          };

          forecast = (forecastData['list'] as List).map((item) {
            return {
              'dateTime': DateTime.parse(item['dt_txt']),
              'temp': item['main']['temp'].toDouble(),
              'icon': item['weather'][0]['icon'],
              'description': item['weather'][0]['description'],
            };
          }).toList();

          isLoading = false;
          errorMessage = null;
        });

        _animationController.forward(from: 0);
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to load weather data';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error fetching weather: $e';
      });
    }
  }

  Future<void> _fetchWeatherByCity(String city) async {
    if (city.trim().isEmpty) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final weatherUrl = 'https://api.openweathermap.org/data/2.5/weather?q=$city&units=metric&appid=$apiKey';
    final forecastUrl = 'https://api.openweathermap.org/data/2.5/forecast?q=$city&units=metric&appid=$apiKey';

    try {
      final weatherResponse = await http.get(Uri.parse(weatherUrl));
      final forecastResponse = await http.get(Uri.parse(forecastUrl));

      if (weatherResponse.statusCode == 200 && forecastResponse.statusCode == 200) {
        final weatherData = json.decode(weatherResponse.body);
        final forecastData = json.decode(forecastResponse.body);

        setState(() {
          temperature = weatherData['main']['temp'].toDouble();
          description = weatherData['weather'][0]['description'];
          cityName = weatherData['name'];
          iconCode = weatherData['weather'][0]['icon'];

          currentWeatherDetails = {
            'wind': weatherData['wind']['speed'],
            'humidity': weatherData['main']['humidity'],
            'pressure': weatherData['main']['pressure'],
            'visibility': weatherData['visibility'] / 1000,
          };

          forecast = (forecastData['list'] as List).map((item) {
            return {
              'dateTime': DateTime.parse(item['dt_txt']),
              'temp': item['main']['temp'].toDouble(),
              'icon': item['weather'][0]['icon'],
              'description': item['weather'][0]['description'],
            };
          }).toList();

          isLoading = false;
          errorMessage = null;
        });

        _animationController.forward(from: 0);
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'City not found or failed to load data';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error fetching weather: $e';
      });
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Location services are disabled.';
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permissions are denied';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'Location permissions are permanently denied.';
    }

    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Weather Forecast', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green[800]!.withOpacity(0.2),
              Colors.grey[50]!,
            ],
          ),
        ),
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(30),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Search city...',
                    prefixIcon: const Icon(Icons.search, color: Colors.green),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.my_location, color: Colors.green),
                      onPressed: () {
                        _determinePosition().then((position) {
                          _fetchWeatherByCoords(position.latitude, position.longitude);
                        });
                      },
                    ),
                  ),
                  onSubmitted: (value) => _fetchWeatherByCity(value),
                ),
              ),
            ),

            // Main Weather Display
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.green))
                  : errorMessage != null
                  ? _buildErrorWidget()
                  : FadeTransition(
                opacity: _fadeAnimation,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      // Current Weather Card
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.blueAccent.withOpacity(0.8),
                                  Colors.green[500]!.withOpacity(0.9),
                                ],
                              ),
                            ),
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                Text(
                                  cityName ?? '',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (iconCode != null)
                                  Image.network(
                                    'https://openweathermap.org/img/wn/$iconCode@4x.png',
                                    width: 120,
                                    height: 120,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                Text(
                                  '${temperature?.toStringAsFixed(1)}°C',
                                  style: const TextStyle(
                                    fontSize: 64,
                                    fontWeight: FontWeight.w300,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  description?.toUpperCase() ?? '',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white.withOpacity(0.9),
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Hourly Forecast
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'HOURLY FORECAST',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 140,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                itemCount: forecast.length,
                                itemBuilder: (context, index) {
                                  final item = forecast[index];
                                  return Container(
                                    width: 90,
                                    margin: const EdgeInsets.only(right: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.white38,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.2),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          Text(
                                            DateFormat('ha').format(item['dateTime']),
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Image.network(
                                            'https://openweathermap.org/img/wn/${item['icon']}@2x.png',
                                            width: 40,
                                            height: 40,
                                          ),
                                          Text(
                                            '${item['temp'].toStringAsFixed(0)}°',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Additional Weather Details
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          children: [
                            _buildDetailCard(
                              icon: Icons.air,
                              title: 'Wind',
                              value: '${currentWeatherDetails?['wind']?.toStringAsFixed(1) ?? '--'} km/h',
                              color: Colors.blue,
                            ),
                            _buildDetailCard(
                              icon: Icons.water_drop,
                              title: 'Humidity',
                              value: '${currentWeatherDetails?['humidity']?.toString() ?? '--'}%',
                              color: Colors.blue,
                            ),
                            _buildDetailCard(
                              icon: Icons.invert_colors,
                              title: 'Pressure',
                              value: '${currentWeatherDetails?['pressure']?.toString() ?? '--'} hPa',
                              color: Colors.blue,
                            ),
                            _buildDetailCard(
                              icon: Icons.visibility,
                              title: 'Visibility',
                              value: '${currentWeatherDetails?['visibility']?.toStringAsFixed(1) ?? '--'} km',
                              color: Colors.blue,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            errorMessage!,
            style: const TextStyle(fontSize: 18, color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              setState(() {
                isLoading = true;
                errorMessage = null;
              });
              _determinePosition().then((position) {
                _fetchWeatherByCoords(position.latitude, position.longitude);
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[800],
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text('Try Again', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard({required IconData icon, required String title, required String value, required MaterialColor color}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: Colors.green[800]),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}