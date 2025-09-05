import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firy_streak/domain/models/quote.dart';
import 'package:firy_streak/domain/repositories/quote_repository.dart';

class QuoteRepositoryApi implements QuoteRepository {
  final String _baseUrl = 'https://firy-streak-api.vercel.app/quotes/random';

  @override
  Future<Quote> fetchRandomQuote() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Quote(text: data['text'] as String);
      } else {
        throw Exception('Failed to load quote');
      }
    } catch (e) {
      throw Exception('Network error fetching quote: $e');
    }
  }
}