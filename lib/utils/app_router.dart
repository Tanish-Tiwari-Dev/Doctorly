import 'package:go_router/go_router.dart';
import '../screens/home_screen.dart';
import '../screens/doctor_details_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/doctor/:id',
      name: 'doctor',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return DoctorDetailsScreen(id: id);
      },
    ),
  ],
);
