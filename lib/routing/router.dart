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

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  final sharedPrefs = ref.watch(sharedPreferencesProvider);
  
  return GoRouter(
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: true,

    redirect: (BuildContext context, GoRouterState state) {
      if (authState.isLoading || sharedPrefs.isLoading) return null;
      if (authState.hasError) return null;

      final isOnboardingComplete =
          sharedPrefs.asData?.value.getBool('onboarding_complete') ?? false;
      final user = authState.value;
      final isLoggedIn = user != null;

      final currentLocation = state.matchedLocation;

      final isOnOnboardingRoute = currentLocation == AppRoutes.onboarding;
      final isOnAuthRoute =
          currentLocation == AppRoutes.login ||
          currentLocation == AppRoutes.register;
      final isOnHomeRoute = currentLocation == AppRoutes.home;

      if (!isOnboardingComplete) {
        if (!isOnOnboardingRoute) {
          return AppRoutes.onboarding;
        }
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
