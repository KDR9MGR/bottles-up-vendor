// Simple event model without code generation

enum EventStatus {
  upcoming,
  ongoing,
  completed,
  cancelled,
}

class EventModel {
  final String id;
  final String title;
  final String description;
  final String clubId;
  final String organizerId;
  final String? imageUrl;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final String location;
  final String address;
  final String? ticketUrl;
  final double ticketPrice;
  final int maxCapacity;
  final int currentAttendees;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;
  final EventStatus status;
  final List<String> tags;
  final Map<String, dynamic> eventDetails;

  const EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.clubId,
    required this.organizerId,
    this.imageUrl,
    required this.startDateTime,
    required this.endDateTime,
    required this.location,
    required this.address,
    this.ticketUrl,
    required this.ticketPrice,
    required this.maxCapacity,
    this.currentAttendees = 0,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
    this.status = EventStatus.upcoming,
    this.tags = const [],
    this.eventDetails = const {},
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      clubId: json['clubId'] as String,
      organizerId: json['organizerId'] as String,
      imageUrl: json['imageUrl'] as String?,
      startDateTime: DateTime.parse(json['startDateTime'] as String),
      endDateTime: DateTime.parse(json['endDateTime'] as String),
      location: json['location'] as String,
      address: json['address'] as String,
      ticketUrl: json['ticketUrl'] as String?,
      ticketPrice: (json['ticketPrice'] as num).toDouble(),
      maxCapacity: json['maxCapacity'] as int,
      currentAttendees: json['currentAttendees'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      isActive: json['isActive'] as bool? ?? true,
      status: EventStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => EventStatus.upcoming,
      ),
      tags: List<String>.from(json['tags'] as List? ?? []),
      eventDetails: Map<String, dynamic>.from(json['eventDetails'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'clubId': clubId,
      'organizerId': organizerId,
      'imageUrl': imageUrl,
      'startDateTime': startDateTime.toIso8601String(),
      'endDateTime': endDateTime.toIso8601String(),
      'location': location,
      'address': address,
      'ticketUrl': ticketUrl,
      'ticketPrice': ticketPrice,
      'maxCapacity': maxCapacity,
      'currentAttendees': currentAttendees,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isActive': isActive,
      'status': status.name,
      'tags': tags,
      'eventDetails': eventDetails,
    };
  }
}

class CreateEventRequest {
  final String title;
  final String description;
  final String clubId;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final String location;
  final String address;
  final String? ticketUrl;
  final double ticketPrice;
  final int maxCapacity;
  final List<String> tags;

  const CreateEventRequest({
    required this.title,
    required this.description,
    required this.clubId,
    required this.startDateTime,
    required this.endDateTime,
    required this.location,
    required this.address,
    this.ticketUrl,
    this.ticketPrice = 0.0,
    required this.maxCapacity,
    this.tags = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'clubId': clubId,
      'startDateTime': startDateTime.toIso8601String(),
      'endDateTime': endDateTime.toIso8601String(),
      'location': location,
      'address': address,
      'ticketUrl': ticketUrl,
      'ticketPrice': ticketPrice,
      'maxCapacity': maxCapacity,
      'tags': tags,
    };
  }
} 