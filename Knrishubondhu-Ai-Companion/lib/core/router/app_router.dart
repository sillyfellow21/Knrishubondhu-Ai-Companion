import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/auth_screen.dart';
import '../../features/chat/presentation/screens/chat_screen.dart';
import '../../features/crop_calendar/presentation/screens/crop_calendar_screen.dart';
import '../../features/forum/presentation/screens/forum_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/lands/presentation/screens/land_details_screen.dart';
import '../../features/lands/presentation/screens/lands_screen.dart';
import '../../features/loans/presentation/screens/loans_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/profile_setup_screen.dart';
import '../../features/weather/presentation/screens/weather_screen.dart';

// Provider for the router
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/auth',
    routes: [
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/profile-setup',
        name: 'profile-setup',
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/chatbot',
        name: 'chatbot',
        builder: (context, state) => const ChatScreen(),
      ),
      GoRoute(
        path: '/weather',
        name: 'weather',
        builder: (context, state) => const WeatherScreen(),
      ),
      GoRoute(
        path: '/lands',
        name: 'lands',
        builder: (context, state) => const LandsScreen(),
      ),
      GoRoute(
        path: '/land-details',
        name: 'land-details',
        builder: (context, state) {
          final land = state.extra;
          if (land == null) {
            return const ErrorScreen();
          }
          return LandDetailsScreen(land: land as dynamic);
        },
      ),
      GoRoute(
        path: '/crop-calendar',
        name: 'crop-calendar',
        builder: (context, state) => const CropCalendarScreen(),
      ),
      GoRoute(
        path: '/loans',
        name: 'loans',
        builder: (context, state) => const LoansScreen(),
      ),
      GoRoute(
        path: '/forum',
        name: 'forum',
        builder: (context, state) => const ForumScreen(),
      ),
    ],
    errorBuilder: (context, state) => const ErrorScreen(),
  );
});

// Error Screen
class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
      ),
      body: const Center(
        child: Text('Page not found'),
      ),
    );
  }
}
