import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Add a new event
  Future<void> addEvent(String userId, Map<String, dynamic> eventData) async {
    try {
      await _db
          .collection('users')
          .doc(userId)
          .collection('events')
          .add(eventData);
      print("Event added successfully.");
    } catch (e) {
      print("Error adding event: $e");
    }
  }

  Future<List<Map<String, dynamic>>> getUserEvents(String userId) async {
    try {
      final querySnapshot =
          await _db.collection('users').doc(userId).collection('events').get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Include the document ID
        return data;
      }).toList();
    } catch (e) {
      print("Error getting user events: $e");
      return [];
    }
  }

  // Update an event
  Future<void> updateEvent(
      String userId, String eventId, Map<String, dynamic> updatedData) async {
    try {
      await _db
          .collection('users')
          .doc(userId)
          .collection('events')
          .doc(eventId)
          .update(updatedData);
      print("Event updated successfully.");
    } catch (e) {
      print("Error updating event: $e");
    }
  }

  // Delete an event
  Future<void> deleteEvent(String userId, String eventId) async {
    try {
      await _db
          .collection('users')
          .doc(userId)
          .collection('events')
          .doc(eventId)
          .delete();
      print("Event deleted successfully.");
    } catch (e) {
      print("Error deleting event: $e");
    }
  }
}
