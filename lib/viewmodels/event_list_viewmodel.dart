import '../services/local_database_service.dart';
import '../models/event_model.dart';

class EventListViewModel {
  final LocalDatabaseService _localDB = LocalDatabaseService();

  // Fetch all events from the database
  Future<List<Event>> getAllEvents() async {
    final eventsData = await _localDB.getAllEvents();
    return eventsData.map((data) => Event.fromMap(data)).toList();
  }

  // Add a new event
  Future<void> addEvent(Event event) async {
    await _localDB.insertEvent(event.toMap());
  }

  // Update an existing event
  Future<void> updateEvent(Event event) async {
    await _localDB.updateEvent(event.toMap(), event.id!);
  }

  // Delete an event
  Future<void> deleteEvent(int id) async {
    await _localDB.deleteEvent(id);
  }

  Future<List<Event>> getAllEventsForUser(String userId) async {
    final eventsData = await _localDB.getEventsByUserId(userId);
    return eventsData.map((data) => Event.fromMap(data)).toList();
  }
}
