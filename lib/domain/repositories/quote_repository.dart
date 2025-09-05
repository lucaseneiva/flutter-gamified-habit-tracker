import 'package:firy_streak/domain/models/quote.dart';

abstract class QuoteRepository {
  Future<Quote> fetchRandomQuote();
}