import 'dart:convert';
import 'package:http/http.dart' as http;

class QuoteService {
  final String _baseUrl = 'https://firy-streak-api.vercel.app/quotes/random';

  Future<String> fetchRandomQuote() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['text'] as String;

      } else {
        return 'Continue firme, a jornada vale a pena!';

      }
    } catch (e) {
      print('Erro ao buscar frases: $e');

      return 'Você é mais forte do que imagina!';
    }
    
  }
}
