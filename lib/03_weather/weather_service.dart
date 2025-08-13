import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class WeatherService {
  static final String _apiKey = dotenv.env['OPENWEATHER_API_KEY'] ?? '';
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5/weather';
  static const String _cacheKey = 'cached_weather';
  static const String _cacheTimestampKey = 'cached_weather_timestamp';

  /// Fetch weather by city with optional caching
  static Future<Map<String, dynamic>> fetchWeather(String city, {bool forceRefresh = false, int cacheExpiryMinutes = 10}) async {
    final cached = await _loadCache();
    if (!forceRefresh && cached != null && cached['name'] == city) {
      return cached;
    }

    final response = await http.get(Uri.parse('$_baseUrl?q=$city&appid=$_apiKey&units=metric'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await _saveCache(data);
      return data;
    } else if (cached != null) {
      // fallback to cached data if API fails
      return cached;
    } else {
      throw Exception('Failed to fetch weather data');
    }
  }

  /// Fetch weather by coordinates with optional caching
  static Future<Map<String, dynamic>> fetchWeatherByCoords(double lat, double lon, {bool forceRefresh = false, int cacheExpiryMinutes = 10}) async {
    final cached = await _loadCache();
    if (!forceRefresh && cached != null) {
      // Optional: You could compare lat/lon to cached coordinates if you store them
      return cached;
    }

    final url = '$_baseUrl?lat=$lat&lon=$lon&appid=$_apiKey&units=metric';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await _saveCache(data);
      return data;
    } else if (cached != null) {
      return cached;
    } else {
      throw Exception('Failed to fetch weather data');
    }
  }

  /// Save weather data to cache with timestamp
  static Future<void> _saveCache(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_cacheKey, json.encode(data));
    prefs.setInt(_cacheTimestampKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Load weather data from cache if not expired
  static Future<Map<String, dynamic>?> _loadCache({int maxAgeMinutes = 10}) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_cacheKey);
    final timestamp = prefs.getInt(_cacheTimestampKey) ?? 0;
    final age = DateTime.now().millisecondsSinceEpoch - timestamp;

    if (jsonString != null && age <= maxAgeMinutes * 60 * 1000) {
      return json.decode(jsonString);
    }
    return null;
  }

  /// Clear cached weather (optional)
  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(_cacheKey);
    prefs.remove(_cacheTimestampKey);
  }
}
