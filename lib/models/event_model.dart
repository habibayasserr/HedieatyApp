import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String? id; // Nullable for Firestore auto-generation
  final String name;
  final String category;
  final DateTime date;
  final String location;
  final String description;

  Event({
    this.id, // Optional id
    required this.name,
    required this.category,
    required this.date,
    required this.location,
    required this.description,
  });

  // Convert Firestore document to Event object
  factory Event.fromJson(Map<String, dynamic> json, String id) {
    return Event(
      id: id,
      name: json['name'] as String,
      category: json['category'] as String,
      date: (json['date'] as Timestamp)
          .toDate(), // Convert Firestore Timestamp to DateTime
      location: json['location'] as String,
      description: json['description'] as String,
    );
  }

  // Convert Event object to Firestore-compatible format
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'date': date,
      'location': location,
      'description': description,
    };
  }
}
