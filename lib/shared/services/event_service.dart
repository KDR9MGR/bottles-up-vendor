import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/event.dart';

class EventService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get all events for the current vendor
  Future<List<Event>> getVendorEvents() async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      final response = await _supabase
          .from('events')
          .select()
          .eq('user_id', userId)
          .order('event_date', ascending: false);

      return (response as List).map((json) => Event.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch events: $e');
    }
  }

  // Get a single event by ID
  Future<Event> getEventById(String eventId) async {
    try {
      final response = await _supabase
          .from('events')
          .select()
          .eq('id', eventId)
          .single();

      return Event.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch event: $e');
    }
  }

  // Create a new event
  Future<Event> createEvent(CreateEventRequest request) async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      final eventData = {
        ...request.toJson(),
        'user_id': userId,
      };

      final response = await _supabase
          .from('events')
          .insert(eventData)
          .select()
          .single();

      return Event.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create event: $e');
    }
  }

  // Update an existing event
  Future<Event> updateEvent(String eventId, UpdateEventRequest request) async {
    try {
      final response = await _supabase
          .from('events')
          .update(request.toJson())
          .eq('id', eventId)
          .select()
          .single();

      return Event.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update event: $e');
    }
  }

  // Delete an event
  Future<void> deleteEvent(String eventId) async {
    try {
      await _supabase
          .from('events')
          .delete()
          .eq('id', eventId);
    } catch (e) {
      throw Exception('Failed to delete event: $e');
    }
  }

  // Get categories for events
  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final response = await _supabase
          .from('categories')
          .select('id, name, description, icon, color')
          .eq('is_active', true)
          .order('name');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  // Get zones for events
  Future<List<Map<String, dynamic>>> getZones() async {
    try {
      final response = await _supabase
          .from('zones')
          .select('id, name, description, capacity, ticket_price, zone_type')
          .eq('is_active', true)
          .order('name');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch zones: $e');
    }
  }

  // Get clubs for events
  Future<List<Map<String, dynamic>>> getClubs() async {
    try {
      final response = await _supabase
          .from('clubs')
          .select('id, name, location')
          .eq('is_active', true)
          .order('name');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch clubs: $e');
    }
  }

  // Upload event images
  Future<List<String>> uploadEventImages(String eventId, List<Uint8List> imageBytes, List<String> fileNames) async {
    try {
      final List<String> imageUrls = [];
      
      for (int i = 0; i < imageBytes.length; i++) {
        final fileExt = fileNames[i].split('.').last;
        final fileName = '$eventId-${DateTime.now().millisecondsSinceEpoch}-$i.$fileExt';
        
        await _supabase.storage
            .from('event-images')
            .uploadBinary(fileName, imageBytes[i]);

        final imageUrl = _supabase.storage
            .from('event-images')
            .getPublicUrl(fileName);

        imageUrls.add(imageUrl);
      }

      return imageUrls;
    } catch (e) {
      throw Exception('Failed to upload images: $e');
    }
  }

  // Get event bookings
  Future<List<Map<String, dynamic>>> getEventBookings(String eventId) async {
    try {
      final response = await _supabase
          .from('events_bookings')
          .select('*, profiles(name, email)')
          .eq('event_id', eventId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch event bookings: $e');
    }
  }
}
