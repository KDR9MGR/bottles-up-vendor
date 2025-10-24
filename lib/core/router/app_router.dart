import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import screens (we'll create these next)
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/database_setup_screen.dart';
import '../../features/auth/screens/debug_screen.dart';
import '../../features/auth/providers/supabase_auth_provider.dart';
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
import '../../features/profile/screens/edit_profile_screen.dart';
import '../../features/profile/screens/business_details_screen.dart';
import '../../features/profile/screens/security_screen.dart';
import '../../features/profile/screens/notifications_screen.dart';
import '../../shared/widgets/main_shell.dart';

// Route names
class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String databaseSetup = '/database-setup';
  static const String debug = '/debug';
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

// Custom page transitions using CupertinoPageRoute
class CupertinoTransitionPage extends CustomTransitionPage<void> {
  const CupertinoTransitionPage({
    required super.child,
    required super.name,
    super.arguments,
    super.restorationId,
    super.key,
  }) : super(
          transitionsBuilder: _cupertinoTransitionsBuilder,
          transitionDuration: const Duration(milliseconds: 400),
          reverseTransitionDuration: const Duration(milliseconds: 400),
        );

  static Widget _cupertinoTransitionsBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return CupertinoPageTransition(
      primaryRouteAnimation: animation,
      secondaryRouteAnimation: secondaryAnimation,
      linearTransition: false,
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
                          state.uri.path == AppRoutes.forgotPassword ||
                          state.uri.path == AppRoutes.databaseSetup ||
                          state.uri.path == AppRoutes.debug;

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
        pageBuilder: (context, state) => CupertinoTransitionPage(
          name: 'login',
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        pageBuilder: (context, state) => CupertinoTransitionPage(
          name: 'register',
          child: const RegisterScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgotPassword',
        pageBuilder: (context, state) => CupertinoTransitionPage(
          name: 'forgotPassword',
          child: const ForgotPasswordScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.databaseSetup,
        name: 'databaseSetup',
        pageBuilder: (context, state) => CupertinoTransitionPage(
          name: 'databaseSetup',
          child: const DatabaseSetupScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.debug,
        name: 'debug',
        pageBuilder: (context, state) => CupertinoTransitionPage(
          name: 'debug',
          child: const DebugScreen(),
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
            pageBuilder: (context, state) => CupertinoTransitionPage(
              name: 'dashboard',
              child: const DashboardScreen(),
            ),
          ),

          // Clubs
          GoRoute(
            path: AppRoutes.clubs,
            name: 'clubs',
            pageBuilder: (context, state) => CupertinoTransitionPage(
              name: 'clubs',
              child: const ClubsListScreen(),
            ),
            routes: [
              GoRoute(
                path: 'create',
                name: 'createClub',
                pageBuilder: (context, state) => CupertinoTransitionPage(
                  name: 'createClub',
                  child: const CreateClubScreen(),
                ),
              ),
              GoRoute(
                path: ':clubId',
                name: 'clubDetails',
                pageBuilder: (context, state) => CupertinoTransitionPage(
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
            pageBuilder: (context, state) => CupertinoTransitionPage(
              name: 'events',
              child: const EventsListScreen(),
            ),
            routes: [
              GoRoute(
                path: 'create',
                name: 'createEvent',
                pageBuilder: (context, state) => CupertinoTransitionPage(
                  name: 'createEvent',
                  child: const CreateEventScreen(),
                ),
              ),
              GoRoute(
                path: ':eventId',
                name: 'eventDetails',
                pageBuilder: (context, state) => CupertinoTransitionPage(
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
            pageBuilder: (context, state) => CupertinoTransitionPage(
              name: 'inventory',
              child: const InventoryScreen(),
            ),
          ),

          // Bookings
          GoRoute(
            path: AppRoutes.bookings,
            name: 'bookings',
            pageBuilder: (context, state) => CupertinoTransitionPage(
              name: 'bookings',
              child: const BookingsScreen(),
            ),
          ),

          // Analytics (placeholder)
          GoRoute(
            path: AppRoutes.analytics,
            name: 'analytics',
            pageBuilder: (context, state) => CupertinoTransitionPage(
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
            pageBuilder: (context, state) => CupertinoTransitionPage(
              name: 'profile',
              child: const ProfileScreen(),
            ),
            routes: [
              GoRoute(
                path: 'edit',
                name: 'editProfile',
                pageBuilder: (context, state) => CupertinoTransitionPage(
                  name: 'editProfile',
                  child: const EditProfileScreen(),
                ),
              ),
              GoRoute(
                path: 'business',
                name: 'businessDetails',
                pageBuilder: (context, state) => CupertinoTransitionPage(
                  name: 'businessDetails',
                  child: const BusinessDetailsScreen(),
                ),
              ),
              GoRoute(
                path: 'security',
                name: 'security',
                pageBuilder: (context, state) => CupertinoTransitionPage(
                  name: 'security',
                  child: const SecurityScreen(),
                ),
              ),
              GoRoute(
                path: 'notifications',
                name: 'notifications',
                pageBuilder: (context, state) => CupertinoTransitionPage(
                  name: 'notifications',
                  child: const NotificationsScreen(),
                ),
              ),
            ],
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