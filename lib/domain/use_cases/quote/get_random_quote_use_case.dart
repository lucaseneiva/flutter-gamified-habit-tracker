import 'package:firy_streak/domain/models/quote.dart';
import 'package:firy_streak/domain/repositories/quote_repository.dart';

class GetRandomQuoteUseCase {
  final QuoteRepository _repository;

  GetRandomQuoteUseCase(this._repository);

  Future<Quote> execute() {
    return _repository.fetchRandomQuote();
  }
}