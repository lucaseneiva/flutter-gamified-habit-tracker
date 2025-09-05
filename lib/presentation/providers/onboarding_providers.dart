import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingNotifier extends Notifier<bool> {
  late SharedPreferences _prefs;

  @override
  bool build() {
    _init(); 
    return false;
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    final isComplete = _prefs.getBool('onboarding_complete') ?? false;
    state = isComplete;
  }

  Future<void> completeOnboarding() async {
    await _prefs.setBool('onboarding_complete', true);
    state = true;
  }
}

final onboardingProvider = NotifierProvider<OnboardingNotifier, bool>(OnboardingNotifier.new);