import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AIService {
  static const String _baseUrl =
      'https://api.groq.com/openai/v1/chat/completions';

  final String _apiKey = dotenv.env['GROQ_API_KEY'] ?? '';

  Future<String> generateDescription(String productName) async {
    final response = await http
        .post(
          Uri.parse(_baseUrl),
          headers: {
            'Authorization': 'Bearer $_apiKey',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            "model": "llama-3.3-70b-versatile",
            "messages": [
              {
                "role": "system",
                "content": "You are an expert e-commerce copywriter."
              },
              {
                "role": "user",
                "content":
                    'Write a professional, engaging and persuasive product description for "$productName". '
                        'Include key features, benefits, and a call to action. '
                        'Format with sections and emojis. Keep it under 200 words.'
              }
            ],
            "temperature": 0.7,
            "max_tokens": 400
          }),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return data['choices'][0]['message']['content'];
    } else {
      throw Exception(_parseApiError(response));
    }
  }

  Future<String> generateDescriptionFromImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();

    final base64Image = base64Encode(bytes);

    final ext = imageFile.path.split('.').last.toLowerCase();

    final mimeType = ext == 'png' ? 'image/png' : 'image/jpeg';

    final response = await http
        .post(
          Uri.parse(_baseUrl),
          headers: {
            'Authorization': 'Bearer $_apiKey',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            "model": "meta-llama/llama-4-scout-17b-16e-instruct",
            "messages": [
              {
                "role": "user",
                "content": [
                  {
                    "type": "text",
                    "text": "Look at this product image and write a professional product description. "
                        "Include product type, key features, benefits, and a call to action. "
                        "Format with sections and emojis. Keep it under 200 words."
                  },
                  {
                    "type": "image_url",
                    "image_url": {"url": "data:$mimeType;base64,$base64Image"}
                  }
                ]
              }
            ],
            "temperature": 0.7,
            "max_tokens": 400
          }),
        )
        .timeout(const Duration(seconds: 60));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return data['choices'][0]['message']['content'];
    } else {
      throw Exception(_parseApiError(response));
    }
  }

  String _parseApiError(http.Response response) {
    try {
      final body = jsonDecode(response.body);

      return body['error']?['message'] ?? 'Unknown API error';
    } catch (_) {
      return response.body;
    }
  }
}
