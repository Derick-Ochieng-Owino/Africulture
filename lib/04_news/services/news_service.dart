import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class NewsService {
  static final String _apiKey = dotenv.env['NEWS_API_KEY'] ?? '';
  static const String _baseUrl = 'https://newsapi.org/v2';

  Future<List<dynamic>> fetchAgricultureNews() async {  // Renamed to match
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/everything?q=agriculture OR farming&apiKey=$_apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['articles'] ?? [];
      } else {
        throw Exception('Failed to fetch news: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch news: $e');
    }
  }
}