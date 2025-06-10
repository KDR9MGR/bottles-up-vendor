import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import screens (we'll create these next)
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/clubs/screens/clubs_list_screen.dart';
import '../../features/clubs/screens/club_details_screen.dart';
import '../../features/clubs/screens/create_club_screen.dart';
import '../../features/events/screens/events_list_screen.dart';
import '../../features/events/screens/event_details_screen.dart';
import '../../features/events/screens/create_event_screen.dart';
import '../../features/events/screens/inventory_screen.dart';
import '../../features/events/screens/bookings_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../shared/widgets/main_shell.dart';

// Route names
class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String dashboard = '/dashboard';
  static const String clubs = '/clubs';
  static const String clubDetails = '/clubs/:clubId';
  static const String createClub = '/clubs/create';
  static const String events = '/events';
  static const String eventDetails = '/events/:eventId';
  static const String createEvent = '/events/create';
  static const String inventory = '/inventory';
  static const String bookings = '/bookings';
  static const String analytics = '/analytics';
  static const String profile = '/profile';
}

// Custom page transitions
class SlideTransitionPage extends CustomTransitionPage<void> {
  const SlideTransitionPage({
    required super.child,
    required super.name,
    super.arguments,
    super.restorationId,
    super.key,
  }) : super(
          transitionsBuilder: _slideTransitionsBuilder,
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 250),
        );

  static Widget _slideTransitionsBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const begin = Offset(1.0, 0.0);
    const end = Offset.zero;
    const curve = Curves.easeInOut;

    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
    var offsetAnimation = animation.drive(tween);

    return SlideTransition(
      position: offsetAnimation,
      child: child,
    );
  }
}

class FadeTransitionPage extends CustomTransitionPage<void> {
  const FadeTransitionPage({
    required super.child,
    required super.name,
    super.arguments,
    super.restorationId,
    super.key,
  }) : super(
          transitionsBuilder: _fadeTransitionsBuilder,
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 250),
        );

  static Widget _fadeTransitionsBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}

// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  final isAuthenticated = ref.watch(isAuthenticatedProvider);
  
  return GoRouter(
    initialLocation: AppRoutes.login,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggedIn = isAuthenticated;
      final isLoggingIn = state.uri.path == AppRoutes.login || 
                          state.uri.path == AppRoutes.register || 
                          state.uri.path == AppRoutes.forgotPassword;

      // If not logged in and not on login/register/forgot password page, redirect to login
      if (!isLoggedIn && !isLoggingIn) {
        return AppRoutes.login;
      }

      // If logged in and on login/register page, redirect to dashboard
      if (isLoggedIn && isLoggingIn) {
        return AppRoutes.dashboard;
      }

      // No redirect needed
      return null;
    },
    routes: [
      // Auth routes (no shell)
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        pageBuilder: (context, state) => FadeTransitionPage(
          name: 'login',
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        pageBuilder: (context, state) => SlideTransitionPage(
          name: 'register',
          child: const RegisterScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgotPassword',
        pageBuilder: (context, state) => SlideTransitionPage(
          name: 'forgotPassword',
          child: const ForgotPasswordScreen(),
        ),
      ),

      // Main shell with bottom navigation
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          // Dashboard
          GoRoute(
            path: AppRoutes.dashboard,
            name: 'dashboard',
            pageBuilder: (context, state) => FadeTransitionPage(
              name: 'dashboard',
              child: const DashboardScreen(),
            ),
          ),

          // Clubs
          GoRoute(
            path: AppRoutes.clubs,
            name: 'clubs',
            pageBuilder: (context, state) => FadeTransitionPage(
              name: 'clubs',
              child: const ClubsListScreen(),
            ),
            routes: [
              GoRoute(
                path: 'create',
                name: 'createClub',
                pageBuilder: (context, state) => SlideTransitionPage(
                  name: 'createClub',
                  child: const CreateClubScreen(),
                ),
              ),
              GoRoute(
                path: ':clubId',
                name: 'clubDetails',
                pageBuilder: (context, state) => SlideTransitionPage(
                  name: 'clubDetails',
                  child: ClubDetailsScreen(
                    clubId: state.pathParameters['clubId']!,
                  ),
                ),
              ),
            ],
          ),

          // Events
          GoRoute(
            path: AppRoutes.events,
            name: 'events',
            pageBuilder: (context, state) => FadeTransitionPage(
              name: 'events',
              child: const EventsListScreen(),
            ),
            routes: [
              GoRoute(
                path: 'create',
                name: 'createEvent',
                pageBuilder: (context, state) => SlideTransitionPage(
                  name: 'createEvent',
                  child: const CreateEventScreen(),
                ),
              ),
              GoRoute(
                path: ':eventId',
                name: 'eventDetails',
                pageBuilder: (context, state) => SlideTransitionPage(
                  name: 'eventDetails',
                  child: EventDetailsScreen(
                    eventId: state.pathParameters['eventId']!,
                  ),
                ),
              ),
            ],
          ),

          // Inventory
          GoRoute(
            path: AppRoutes.inventory,
            name: 'inventory',
            pageBuilder: (context, state) => FadeTransitionPage(
              name: 'inventory',
              child: const InventoryScreen(),
            ),
          ),

          // Bookings
          GoRoute(
            path: AppRoutes.bookings,
            name: 'bookings',
            pageBuilder: (context, state) => FadeTransitionPage(
              name: 'bookings',
              child: const BookingsScreen(),
            ),
          ),

          // Analytics (placeholder)
          GoRoute(
            path: AppRoutes.analytics,
            name: 'analytics',
            pageBuilder: (context, state) => FadeTransitionPage(
              name: 'analytics',
              child: const Scaffold(
                appBar: null,
                body: Center(
                  child: Text('Analytics - Coming Soon'),
                ),
              ),
            ),
          ),

          // Profile
          GoRoute(
            path: AppRoutes.profile,
            name: 'profile',
            pageBuilder: (context, state) => FadeTransitionPage(
              name: 'profile',
              child: const ProfileScreen(),
            ),
          ),
        ],
      ),
    ],
  );
});

// Router helper extensions
extension GoRouterExtensions on GoRouter {
  void pushAndClearStack(String location) {
    while (canPop()) {
      pop();
    }
    pushReplacement(location);
  }
} 