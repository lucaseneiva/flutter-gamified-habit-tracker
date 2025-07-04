import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/quote_service.dart';

final quoteServiceProvider = Provider<QuoteService>((ref) {
  return QuoteService();
});

final randomQuoteProvider = FutureProvider.autoDispose<String>((ref) {
  final service = ref.watch(quoteServiceProvider);
  return service.fetchRandomQuote();
});

