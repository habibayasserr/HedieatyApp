class Event {
  final int? id;
  final String name;
  final String category;
  final DateTime date;
  final String location;
  final String description;
  final String userId; // Change to String to align with Firebase user ID

  Event({
    this.id,
    required this.name,
    required this.category,
    required this.date,
    required this.location,
    required this.description,
    required this.userId,
  });

  // Convert Event to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'date': date.toIso8601String(),
      'location': location,
      'description': description,
      'user_id': userId, // Use string user ID here
    };
  }

  // Convert Map to Event for reading from database
  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      date: DateTime.parse(map['date']),
      location: map['location'],
      description: map['description'],
      userId: map['user_id'], // Ensure this aligns with string
    );
  }
}
