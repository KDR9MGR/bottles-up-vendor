import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get event statistics
  Future<Map<String, dynamic>> getEventStats() async {
    try {
      final snapshot = await _firestore.collection('events').get();
      final events = snapshot.docs;
      
      final now = DateTime.now();
      final upcomingEvents = events.where((doc) {
        final data = doc.data();
        if (data['date'] != null) {
          final eventDate = (data['date'] as Timestamp).toDate();
          return eventDate.isAfter(now);
        }
        return false;
      }).length;

      return {
        'total': events.length,
        'upcoming': upcomingEvents,
      };
    } catch (e) {
      return {'total': 0, 'upcoming': 0};
    }
  }

  // Get booking statistics
  Future<Map<String, dynamic>> getBookingStats() async {
    try {
      final snapshot = await _firestore.collection('bookings').get();
      final bookings = snapshot.docs;
      
      double totalRevenue = 0.0;
      for (final doc in bookings) {
        final data = doc.data();
        totalRevenue += (data['totalPrice'] as num?)?.toDouble() ?? 0.0;
      }

      return {
        'total': bookings.length,
        'revenue': totalRevenue,
      };
    } catch (e) {
      return {'total': 0, 'revenue': 0.0};
    }
  }

  // Get inventory statistics
  Future<Map<String, dynamic>> getInventoryStats() async {
    try {
      final snapshot = await _firestore.collection('inventory').get();
      final inventory = snapshot.docs;
      
      final featuredCount = inventory.where((doc) {
        final data = doc.data();
        return data['featured'] == true;
      }).length;

      return {
        'total': inventory.length,
        'featured': featuredCount,
      };
    } catch (e) {
      return {'total': 0, 'featured': 0};
    }
  }

  // Get recent events with booking data
  Future<List<Map<String, dynamic>>> getRecentEvents() async {
    try {
      final eventsSnapshot = await _firestore
          .collection('events')
          .orderBy('date', descending: true)
          .limit(5)
          .get();

      final List<Map<String, dynamic>> recentEvents = [];

      for (final eventDoc in eventsSnapshot.docs) {
        final eventData = eventDoc.data();
        
        // Get bookings for this event
        final bookingsSnapshot = await _firestore
            .collection('bookings')
            .where('eventId', isEqualTo: eventDoc.id)
            .get();

        double eventRevenue = 0.0;
        for (final booking in bookingsSnapshot.docs) {
          final bookingData = booking.data();
          eventRevenue += (bookingData['totalPrice'] as num?)?.toDouble() ?? 0.0;
        }

        recentEvents.add({
          'id': eventDoc.id,
          'title': eventData['title'] ?? 'Unknown Event',
          'venue': eventData['venue'] ?? 'Unknown Venue',
          'date': eventData['date'] != null 
              ? (eventData['date'] as Timestamp).toDate().toIso8601String()
              : DateTime.now().toIso8601String(),
          'bookings': bookingsSnapshot.docs.length,
          'revenue': eventRevenue,
        });
      }

      return recentEvents;
    } catch (e) {
      return [];
    }
  }

  // Get all events
  Future<List<Map<String, dynamic>>> getAllEvents() async {
    try {
      final snapshot = await _firestore
          .collection('events')
          .orderBy('date', descending: false)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Get all bookings
  Future<List<Map<String, dynamic>>> getAllBookings() async {
    try {
      final snapshot = await _firestore
          .collection('bookings')
          .orderBy('bookedAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Get all inventory
  Future<List<Map<String, dynamic>>> getAllInventory() async {
    try {
      final snapshot = await _firestore
          .collection('inventory')
          .orderBy('name')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Get categories
  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final snapshot = await _firestore.collection('categories').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Add new event
  Future<String?> addEvent(Map<String, dynamic> eventData) async {
    try {
      final docRef = await _firestore.collection('events').add(eventData);
      return docRef.id;
    } catch (e) {
      return null;
    }
  }

  // Update event
  Future<bool> updateEvent(String eventId, Map<String, dynamic> eventData) async {
    try {
      await _firestore.collection('events').doc(eventId).update(eventData);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Delete event
  Future<bool> deleteEvent(String eventId) async {
    try {
      await _firestore.collection('events').doc(eventId).delete();
      return true;
    } catch (e) {
      return false;
    }
  }
}

final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
}); 