import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/dashboard_stats.dart';

class DashboardService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get dashboard statistics for the current vendor
  Future<DashboardStats> getDashboardStats() async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      final response = await _supabase
          .from('dashboard_stats')
          .select()
          .eq('vendor_id', userId)
          .single();

      return DashboardStats.fromJson(response);
    } catch (e) {
      // If no stats found, return default stats
      final userId = _supabase.auth.currentUser!.id;
      return DashboardStats(
        vendorId: userId,
        totalEvents: 0,
        upcomingEvents: 0,
        activeEvents: 0,
        totalBookings: 0,
        monthlyBookings: 0,
        confirmedBookings: 0,
        inventoryCount: 0,
        featuredItems: 0,
        lowStockItems: 0,
        monthlyRevenue: 0.0,
        confirmedRevenue: 0.0,
      );
    }
  }

  // Get recent activity
  Future<Map<String, dynamic>> getRecentActivity() async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      
      // Get recent events
      final recentEvents = await _supabase
          .from('vendor_events')
          .select('id, title, date, status')
          .eq('vendor_id', userId)
          .order('created_at', ascending: false)
          .limit(5);

      // Get recent bookings
      final recentBookings = await _supabase
          .from('vendor_bookings')
          .select('id, customer_name, total_amount, status, created_at')
          .eq('vendor_id', userId)
          .order('created_at', ascending: false)
          .limit(5);

      // Get recent inventory updates
      final recentInventory = await _supabase
          .from('vendor_inventory')
          .select('id, name, stock, updated_at')
          .eq('vendor_id', userId)
          .order('updated_at', ascending: false)
          .limit(5);

      return {
        'recent_events': recentEvents,
        'recent_bookings': recentBookings,
        'recent_inventory': recentInventory,
      };
    } catch (e) {
      throw Exception('Failed to fetch recent activity: $e');
    }
  }

  // Get revenue trends (last 6 months)
  Future<List<Map<String, dynamic>>> getRevenueTrends() async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      
      final response = await _supabase
          .rpc('get_revenue_trends', params: {'vendor_id': userId});

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      // If function doesn't exist, return empty list
      return [];
    }
  }

  // Get top performing events
  Future<List<Map<String, dynamic>>> getTopPerformingEvents() async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      
      final response = await _supabase
          .from('vendor_events')
          .select('id, title, booked_seats, capacity, price')
          .eq('vendor_id', userId)
          .order('booked_seats', ascending: false)
          .limit(5);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch top performing events: $e');
    }
  }

  // Get low stock alerts
  Future<List<Map<String, dynamic>>> getLowStockAlerts() async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      
      final response = await _supabase
          .from('vendor_inventory')
          .select('id, name, stock, min_stock, category')
          .eq('vendor_id', userId)
          .lte('stock', 'min_stock')
          .order('stock', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch low stock alerts: $e');
    }
  }
}
