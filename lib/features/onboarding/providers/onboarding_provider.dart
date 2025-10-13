import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingState {
  final bool hasSeenOnboarding;
  final int currentPage;

  const OnboardingState({
    this.hasSeenOnboarding = false,
    this.currentPage = 0,
  });

  OnboardingState copyWith({
    bool? hasSeenOnboarding,
    int? currentPage,
  }) {
    return OnboardingState(
      hasSeenOnboarding: hasSeenOnboarding ?? this.hasSeenOnboarding,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  OnboardingNotifier() : super(const OnboardingState()) {
    _loadOnboardingStatus();
  }

  static const String _onboardingKey = 'has_seen_onboarding';

  Future<void> _loadOnboardingStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasSeenOnboarding = prefs.getBool(_onboardingKey) ?? false;
      state = state.copyWith(hasSeenOnboarding: hasSeenOnboarding);
    } catch (e) {
      // Handle error silently, defaults to false
    }
  }

  void setCurrentPage(int page) {
    state = state.copyWith(currentPage: page);
  }

  Future<void> completeOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_onboardingKey, true);
      state = state.copyWith(hasSeenOnboarding: true);
    } catch (e) {
      // Handle error
      rethrow;
    }
  }

  Future<void> resetOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_onboardingKey, false);
      state = state.copyWith(hasSeenOnboarding: false, currentPage: 0);
    } catch (e) {
      // Handle error
      rethrow;
    }
  }
}

final onboardingProvider = StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
  return OnboardingNotifier();
});


