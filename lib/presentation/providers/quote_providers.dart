import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firy_streak/data/repositories/quote_repository_api.dart';
import 'package:firy_streak/domain/models/quote.dart';
import 'package:firy_streak/domain/repositories/quote_repository.dart';
import 'package:firy_streak/domain/use_cases/quote/get_random_quote_use_case.dart';

final quoteRepositoryProvider = Provider<QuoteRepository>((ref) {
  return QuoteRepositoryApi();
});

final getRandomQuoteUseCaseProvider = Provider<GetRandomQuoteUseCase>((ref) {
  final repository = ref.watch(quoteRepositoryProvider);
  return GetRandomQuoteUseCase(repository);
});

final randomQuoteProvider = FutureProvider.autoDispose<Quote>((ref) {
  final useCase = ref.watch(getRandomQuoteUseCaseProvider);
  return useCase.execute();
});