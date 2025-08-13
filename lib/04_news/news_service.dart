import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NewsService {
  static final String _apiKey = dotenv.env['NEWS_API_KEY'] ?? '';
  static const String _baseUrl = 'https://newsapi.org/v2';
  static const String _cacheKey = 'cached_news';

  Future<List<dynamic>> fetchAgricultureNews({bool forceRefresh = false}) async {
    final prefs = await SharedPreferences.getInstance();

    if (!forceRefresh && prefs.containsKey(_cacheKey)) {
      final cachedData = prefs.getString(_cacheKey);
      if (cachedData != null) {
        return json.decode(cachedData);
      }
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/everything?q=agriculture OR farming&apiKey=$_apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['articles'] ?? [];
        await prefs.setString(_cacheKey, json.encode(data));

        return data;
      } else {
        throw Exception('Failed to fetch news: ${response.statusCode}');
      }
    } catch (e) {
      if (prefs.containsKey(_cacheKey)) {
        final cachedData = prefs.getString(_cacheKey);
        if (cachedData != null) {
          return json.decode(cachedData);
        }
      }
      throw Exception('Failed to fetch news: $e');
    }
  }
}
