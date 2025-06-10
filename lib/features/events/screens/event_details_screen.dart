import 'package:flutter/material.dart';

class EventDetailsScreen extends StatelessWidget {
  final String eventId;
  
  const EventDetailsScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Event Details')),
      body: Center(child: Text('Event Details for ID: $eventId - Coming Soon')),
    );
  }
} 