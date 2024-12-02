import 'package:http/http.dart' as http;
import 'dart:convert';

class TranslationService {
  static const String _subscriptionKey =
      'CT3JSIJ45spE4BGdXPjaZs99r9nDrCr4b9nkSLRTukt5tfg1JyhdJQQJ99ALAC5RqLJXJ3w3AAAbACOGunJW';
  static const String _endpoint =
      'https://api.cognitive.microsofttranslator.com/translate?api-version=3.0';

  static Future<String> translateText(String text) async {
    final url = Uri.parse('$_endpoint&from=pt&to=en');

    final response = await http.post(
      url,
      headers: {
        'Ocp-Apim-Subscription-Key': _subscriptionKey,
        'Content-Type': 'application/json',
        'Ocp-Apim-Subscription-Region': 'westeurope', // e.g., 'westus'
      },
      body: json.encode([
        {'Text': text}
      ]),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse[0]['translations'][0]['text'];
    } else {
      throw Exception('Failed to translate text');
    }
  }
}
