import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  static final String apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  static const endpoint ='https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro-latest:generateContent';

  // ✅ Text-only prompt
  static Future<String> getGeminiResponse(String userInput) async {
    final response = await http.post(
      Uri.parse('$endpoint?key=$apiKey'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": userInput}
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text']
          .replaceAll("**", "");
    } else {
      debugPrint("Error: ${response.body}");
      throw Exception('Failed to get Gemini response');
    }
  }

  static Future<String> sendImageWithPrompt(String imageUrl, String prompt) async {
    final response = await http.post(
      Uri.parse('$endpoint?key=$apiKey'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": prompt},
              {
                "fileData": {
                  "mimeType": "image/jpeg",
                  "fileUri": imageUrl
                }
              }
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text']
          .replaceAll("**", "");
    } else {
      debugPrint("Error: ${response.body}");
      throw Exception('Failed to get image diagnosis');
    }
  }
}
