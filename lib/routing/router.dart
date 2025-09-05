import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firy_streak/presentation/providers/auth_providers.dart';
import 'package:firy_streak/routing/routes.dart';

import 'package:firy_streak/presentation/auth/login_screen.dart';
import 'package:firy_streak/presentation/auth/register_screen.dart';
import 'package:firy_streak/presentation/habit/home_screen.dart';
import 'package:firy_streak/presentation/habit/create_habit_screen.dart';
import 'package:firy_streak/presentation/habit/onboarding_screen.dart';
import 'package:firy_streak/presentation/providers/shared_preferences_provider.dart';

// 1. Create a provider for your GoRouter instance
final routerProvider = Provider<GoRouter>((ref) {
  // Watch the auth state provider. GoRouter will automatically rebuild
  // and re-run the redirect logic whenever this state changes.
  final authState = ref.watch(authStateChangesProvider);
  final sharedPrefs = ref.watch(sharedPreferencesProvider);

  return GoRouter(
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: true,

    redirect: (BuildContext context, GoRouterState state) {
      // Early returns for loading states
      if (authState.isLoading || sharedPrefs.isLoading) return null;
      if (authState.hasError) return null;

      final isOnboardingComplete =
          sharedPrefs.asData?.value.getBool('onboarding_complete') ?? false;
      final user = authState.value;
      final isLoggedIn = user != null;

      final currentLocation = state.matchedLocation;

      // Define route checks
      final isOnOnboardingRoute = currentLocation == AppRoutes.onboarding;
      final isOnAuthRoute =
          currentLocation == AppRoutes.login ||
          currentLocation == AppRoutes.register;
      final isOnHomeRoute = currentLocation == AppRoutes.home;

      // 1. Handle onboarding flow
      if (!isOnboardingComplete) {
        // If onboarding is not complete, only allow onboarding route
        if (!isOnOnboardingRoute) {
          return AppRoutes.onboarding;
        }
        // If already on onboarding route, stay there
        return null;
      }

      // 2. Handle authenticated users
      if (isLoggedIn) {
        // If logged in and trying to access auth or onboarding routes, redirect to home
        if (isOnAuthRoute || isOnOnboardingRoute) {
          return AppRoutes.home;
        }
        // Otherwise, allow access
        return null;
      }

      // 3. Handle unauthenticated users (onboarding complete but not logged in)
      if (!isOnAuthRoute) {
        return AppRoutes.login;
      }

      // If on auth route and not logged in, allow access
      return null;
    },

    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.createHabit,
        builder: (context, state) => const CreateHabitScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
    ],
  );
});
