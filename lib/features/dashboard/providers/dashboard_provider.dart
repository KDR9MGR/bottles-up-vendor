import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/services/firebase_service.dart';

class DashboardData {
  final int totalEvents;
  final int upcomingEvents;
  final int totalBookings;
  final int inventoryCount;
  final int featuredBottles;
  final double totalRevenue;
  final List<Map<String, dynamic>> recentEvents;

  DashboardData({
    required this.totalEvents,
    required this.upcomingEvents,
    required this.totalBookings,
    required this.inventoryCount,
    required this.featuredBottles,
    required this.totalRevenue,
    required this.recentEvents,
  });
}

final dashboardProvider = FutureProvider<DashboardData>((ref) async {
  final firebaseService = ref.read(firebaseServiceProvider);
  
  try {
    // Fetch all the data concurrently
    final eventStatsFuture = firebaseService.getEventStats();
    final bookingStatsFuture = firebaseService.getBookingStats();
    final inventoryStatsFuture = firebaseService.getInventoryStats();
    final recentEventsFuture = firebaseService.getRecentEvents();

    final results = await Future.wait([
      eventStatsFuture,
      bookingStatsFuture,
      inventoryStatsFuture,
      recentEventsFuture,
    ]);

    final eventStats = results[0] as Map<String, dynamic>;
    final bookingStats = results[1] as Map<String, dynamic>;
    final inventoryStats = results[2] as Map<String, dynamic>;
    final recentEvents = results[3] as List<Map<String, dynamic>>;

    return DashboardData(
      totalEvents: eventStats['total'] ?? 0,
      upcomingEvents: eventStats['upcoming'] ?? 0,
      totalBookings: bookingStats['total'] ?? 0,
      inventoryCount: inventoryStats['total'] ?? 0,
      featuredBottles: inventoryStats['featured'] ?? 0,
      totalRevenue: bookingStats['revenue'] ?? 0.0,
      recentEvents: recentEvents,
    );
  } catch (e) {
    // Return default data if Firebase fails
    return DashboardData(
      totalEvents: 0,
      upcomingEvents: 0,
      totalBookings: 0,
      inventoryCount: 0,
      featuredBottles: 0,
      totalRevenue: 0.0,
      recentEvents: [],
    );
  }
}); 