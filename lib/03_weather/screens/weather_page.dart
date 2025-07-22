import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> with SingleTickerProviderStateMixin {
  final String apiKey = 'edfccaac97b65ee256139a90346962ad';

  bool isLoading = true;
  String? errorMessage;

  double? temperature;
  String? description;
  String? cityName;
  String? iconCode;

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
      duration: Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _determinePosition().then((position) {
      _fetchWeatherByCoords(position.latitude, position.longitude);
      _refreshTimer = Timer.periodic(Duration(minutes: 5), (_) {
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
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Location services are disabled.';
    }

    permission = await Geolocator.checkPermission();
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

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month} ${dt.hour.toString().padLeft(2, '0')}:00';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Real-time Weather'),
        backgroundColor: Colors.green,
      ),
      body: Container(
        color: Colors.black12,
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search city',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onSubmitted: (value) {
                      _fetchWeatherByCity(value);
                      FocusScope.of(context).unfocus();
                    },
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    _fetchWeatherByCity(_searchController.text);
                    FocusScope.of(context).unfocus();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: Text('Search'),
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : errorMessage != null
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      errorMessage!,
                      style: TextStyle(color: Colors.red, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isLoading = true;
                          errorMessage = null;
                        });
                        _determinePosition().then((position) {
                          _fetchWeatherByCoords(position.latitude, position.longitude);
                        }).catchError((e) {
                          setState(() {
                            isLoading = false;
                            errorMessage = 'Could not get location: $e';
                          });
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: Text('Retry Location'),
                    ),
                  ],
                ),
              )
                  : FadeTransition(
                opacity: _fadeAnimation,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      if (iconCode != null)
                        Image.network(
                          'https://openweathermap.org/img/wn/$iconCode@4x.png',
                          width: 150,
                          height: 150,
                        ),
                      Text(
                        cityName ?? '',
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${temperature?.toStringAsFixed(1)} °C',
                        style: TextStyle(fontSize: 48),
                      ),
                      SizedBox(height: 8),
                      Text(
                        description?.toUpperCase() ?? '',
                        style: TextStyle(fontSize: 24),
                      ),
                      SizedBox(height: 24),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '5-Day Forecast',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: 12),
                      SizedBox(
                        height: 140,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: forecast.length,
                          itemBuilder: (context, index) {
                            final item = forecast[index];
                            return Container(
                              width: 100,
                              margin: EdgeInsets.only(right: 12),
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Text(
                                    _formatDateTime(item['dateTime']),
                                    style: TextStyle(fontSize: 12),
                                    textAlign: TextAlign.center,
                                  ),
                                  Image.network(
                                    'https://openweathermap.org/img/wn/${item['icon']}@2x.png',
                                    width: 50,
                                    height: 50,
                                  ),
                                  Text(
                                    '${item['temp'].toStringAsFixed(1)} °C',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    item['description'].toString().toUpperCase(),
                                    style: TextStyle(fontSize: 10),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            );
                          },
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
}
