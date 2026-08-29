import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../screens/appointments_screen.dart';
import '../screens/auth_screen.dart';
import '../screens/booking_screen.dart';
import '../screens/doctor_details_screen.dart';
import '../screens/favorites_screen.dart';
import '../screens/home_screen.dart';
import '../screens/onboarding_screen.dart';
import '../widgets/bottom_nav_scaffold.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter buildAppRouter(ProviderContainer container) {
  final refresh = ValueNotifier<int>(0);
  container.listen<AsyncValue<AuthState>>(
    authProvider,
    (_, _) => refresh.value++,
    fireImmediately: false,
  );

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/onboarding',
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = container.read(authProvider);
      final isAuthLoading = auth.isLoading || !auth.hasValue;
      if (isAuthLoading) return null;

      final session = auth.valueOrNull;
      final signedIn = session?.isSignedIn ?? false;
      final loc = state.matchedLocation;

      const publicPaths = {'/onboarding', '/login'};
      if (!signedIn) {
        if (publicPaths.contains(loc)) return null;
        return '/onboarding';
      }
      if (signedIn && (loc == '/onboarding' || loc == '/login')) {
        return '/home';
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
      GoRoute(
        path: '/home',
        name: 'home',
        redirect: (context, state) => '/',
      ),
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
    ],
  );
}
