import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../providers/onboarding_provider.dart';
import '../screens/appointments_screen.dart';
import '../screens/auth_screen.dart';
import '../screens/booking_screen.dart';
import '../screens/doctor_details_screen.dart';
import '../screens/favorites_screen.dart';
import '../screens/home_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/settings_screen.dart';
import '../widgets/bottom_nav_scaffold.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter buildAppRouter(ProviderContainer container) {
  final refresh = ValueNotifier<int>(0);
  container.listen<AsyncValue<AuthState>>(
    authProvider,
    (_, _) => refresh.value++,
    fireImmediately: true,
  );
  container.listen<AsyncValue<bool>>(
    onboardingProvider,
    (_, _) => refresh.value++,
    fireImmediately: true,
  );

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/onboarding',
    refreshListenable: refresh,
    redirect: (context, state) {
      final authAsync = container.read(authProvider);
      final onboardingAsync = container.read(onboardingProvider);

      final isLoading =
          authAsync.isLoading ||
          onboardingAsync.isLoading ||
          !authAsync.hasValue ||
          !onboardingAsync.hasValue;

      final loc = state.matchedLocation;

      // 1. While loading state, keep the user on /onboarding or /login,
      // preventing premature access to protected routes like /
      if (isLoading) {
        if (loc == '/onboarding' || loc == '/login') {
          return null;
        }
        return '/onboarding';
      }

      final hasSeenOnboarding = onboardingAsync.valueOrNull ?? false;
      final signedIn = authAsync.valueOrNull?.isSignedIn ?? false;

      // 2. Force Onboarding if not completed
      if (!hasSeenOnboarding) {
        return loc == '/onboarding' ? null : '/onboarding';
      }

      // 3. Force Login if not authenticated
      if (!signedIn) {
        return loc == '/login' ? null : '/login';
      }

      // 4. Only allow access to protected routes (e.g. /) when both onboarding and auth are complete
      if (loc == '/onboarding' || loc == '/login') {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(path: '/home', name: 'home', redirect: (context, state) => '/'),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return BottomNavScaffold(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                name: 'homeShell',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/favorites',
                name: 'favorites',
                builder: (context, state) => const FavoritesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/appointments',
                name: 'appointments',
                builder: (context, state) => const AppointmentsScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/doctor/:id',
        name: 'doctor',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return DoctorDetailsScreen(id: id);
        },
      ),
      GoRoute(
        path: '/booking/:doctorId',
        name: 'booking',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final doctorId = state.pathParameters['doctorId']!;
          return BookingScreen(doctorId: doctorId);
        },
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}
