import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class FirestoreTestView extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final user =
        FirebaseAuth.instance.currentUser; // Get the authenticated user
    final userId = user?.uid; // Extract the user's unique ID (uid)

    if (userId == null) {
      return const Scaffold(
        body: Center(
          child: Text('User not authenticated. Please log in first.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Firestore Test')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                await _firestoreService.addEvent(userId, {
                  'name': 'Birthday Party',
                  'date': '2024-12-25',
                  'location': 'Home',
                  'description': 'Celebrate John\'s birthday.'
                });
              },
              child: const Text('Add Event'),
            ),
            ElevatedButton(
              onPressed: () async {
                final events = await _firestoreService.getUserEvents(userId);
                print("Fetched Events: $events");
              },
              child: const Text('Get Events'),
            ),
            ElevatedButton(
              onPressed: () async {
                const eventId =
                    "eventId"; // Replace with an actual event ID from Firestore.
                await _firestoreService.updateEvent(userId, eventId, {
                  'name': 'Updated Birthday Party',
                });
              },
              child: const Text('Update Event'),
            ),
            ElevatedButton(
              onPressed: () async {
                const eventId =
                    "eventId"; // Replace with an actual event ID from Firestore.
                await _firestoreService.deleteEvent(userId, eventId);
              },
              child: const Text('Delete Event'),
            ),
          ],
        ),
      ),
    );
  }
}
