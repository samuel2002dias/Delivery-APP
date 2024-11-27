import 'package:http/http.dart' as http;
import 'dart:convert';

class TranslationService {
  static const String _apiKey = 'AIzaSyADmDdOWPT8Pc91A8uXm2BnwVHlRT4tlcc';

  static Future<String> translateText(String text) async {
    final url = Uri.parse(
        'https://translation.googleapis.com/language/translate/v2?key=$_apiKey');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'q': text,
        'source': 'pt', // Set source language to Portuguese
        'target': 'en', // Set target language to English
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse['data']['translations'][0]['translatedText'];
    } else {
      throw Exception('Failed to translate text');
    }
  }
}
