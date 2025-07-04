import 'package:flutter_riverpod/flutter_riverpod.dart';

final authIsLoadingProvider = StateProvider<bool>((ref) {
  return false;
});