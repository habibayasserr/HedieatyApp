import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/event_model.dart';
import '../widgets/custom_header.dart';
import '../widgets/custom_footer.dart';
import '../views/gift_list_view.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EventListView extends StatefulWidget {
  const EventListView({Key? key}) : super(key: key);

  @override
  _EventListViewState createState() => _EventListViewState();
}

class _EventListViewState extends State<EventListView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;
  Future<void> deleteEvent(String eventId) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    try {
      // Fetch all gifts in the event's gifts subcollection
      final giftsSnapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('events')
          .doc(eventId)
          .collection('gifts')
          .get();

      // Delete each gift document
      for (var giftDoc in giftsSnapshot.docs) {
        await giftDoc.reference.delete();
      }

      // Finally, delete the event document
      await firestore
          .collection('users')
          .doc(userId)
          .collection('events')
          .doc(eventId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Event and its gifts deleted successfully!')),
      );
    } catch (e) {
      print('Error deleting event and its gifts: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete event.')),
      );
    }
  }

  String selectedSortOption = 'Sort by Name (Ascending)';

  // Calculate event status dynamically
  String _calculateStatus(DateTime eventDate) {
    final today = DateTime.now();
    if (eventDate.isAfter(today)) {
      return 'Upcoming';
    } else if (eventDate.difference(today).inDays.abs() == 0) {
      return 'Current';
    } else {
      return 'Past';
    }
  }

  // Sort events based on the selected criteria
  void _sortEvents(List<Event> events) {
    switch (selectedSortOption) {
      case 'Sort by Name (Ascending)':
        events.sort((a, b) => a.name.compareTo(b.name));
        break;

      case 'Sort by Name (Descending)':
        events.sort((a, b) => b.name.compareTo(a.name));
        break;

      case 'Sort by Upcoming Events':
        events.sort((a, b) => b.date.compareTo(a.date));
        break;

      case 'Sort by Current Events':
        events.sort((a, b) {
          final statusA = _calculateStatus(a.date);
          final statusB = _calculateStatus(b.date);
          return (statusA == 'Current' ? 0 : 1) -
              (statusB == 'Current' ? 0 : 1);
        });
        break;

      case 'Sort by Past Events':
        events.sort((a, b) => a.date.compareTo(b.date));
        break;

      case 'Sort by Category':
        events.sort((a, b) => a.category.compareTo(b.category));
        break;
    }
  }

// Firestore Stream for fetching events
  Stream<List<Event>> _fetchEvents() {
    if (_userId == null) {
      return const Stream.empty(); // Handle null user case gracefully
    }
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('events')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return Event.fromJson(doc.data(), doc.id);
            }).toList());
  }

  // Dialog for adding or editing events
  void _showEventDialog({Event? event, int? index}) {
    final TextEditingController nameController =
        TextEditingController(text: event?.name);
    final TextEditingController locationController =
        TextEditingController(text: event?.location);
    final TextEditingController descriptionController =
        TextEditingController(text: event?.description);
    DateTime? selectedDate = event?.date;
    String selectedCategory = event?.category ?? 'Birthday';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(event == null ? 'Add Event' : 'Edit Event'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Event Name',
                    hintText: 'Enter event name',
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  items: [
                    'Birthday',
                    'Wedding',
                    'Graduation',
                    'Holiday',
                    'Engagement'
                  ].map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedCategory = value;
                      });
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'Category',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    hintText: 'Enter event location',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Enter event description',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text('Date: '),
                    Text(
                      selectedDate != null
                          ? DateFormat('dd-MM-yyyy').format(selectedDate!)
                          : 'Select Date',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            selectedDate = pickedDate;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final location = locationController.text.trim();
                final description = descriptionController.text.trim();

                if (name.isEmpty || location.isEmpty || description.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill in all fields'),
                    ),
                  );
                  return;
                }

                // Add new event to Firestore
                if (event == null) {
                  await _firestore
                      .collection('users')
                      .doc(_userId)
                      .collection('events')
                      .add({
                    'name': name,
                    'category': selectedCategory,
                    'date': selectedDate ?? DateTime.now(),
                    'location': location,
                    'description': description,
                  });
                } else {
                  // Update existing event
                  await _firestore
                      .collection('users')
                      .doc(_userId)
                      .collection('events')
                      .doc(event.id)
                      .update({
                    'name': name,
                    'category': selectedCategory,
                    'date': selectedDate ?? DateTime.now(),
                    'location': location,
                    'description': description,
                  });
                }

                Navigator.pop(context); // Close dialog
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomHeader(
        title: 'Events',
        onProfileTap: () {
          // Navigate to profile
        },
        onNotificationTap: () {
          // Navigate to notifications
        },
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              key: const Key('events_sort_dropdown'),
              value: selectedSortOption,
              items: [
                'Sort by Name (Ascending)',
                'Sort by Name (Descending)',
                'Sort by Upcoming Events',
                'Sort by Current Events',
                'Sort by Past Events',
                'Sort by Category',
              ].map((sortOption) {
                return DropdownMenuItem(
                  value: sortOption,
                  child: Text(sortOption),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedSortOption = value;
                  });
                }
              },
              isExpanded: true,
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Event>>(
              stream: _fetchEvents(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Error fetching events.'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No events found.'));
                }

                final events = snapshot.data!;
                _sortEvents(events); // Apply sorting

                return ListView.builder(
                  key: const Key('events_list_view'),
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return Card(
                      key: Key('event_card_$index'),
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(
                          event.name,
                          key: Key('event_name_$index'),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Text(
                          'Date: ${DateFormat('dd-MM-yyyy').format(event.date)}\nCategory: ${event.category}',
                          key: Key('event_details_$index'),
                          style:
                              const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GiftListView(event: event),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('add_event_fab'),
        onPressed: () {
          _showEventDialog();
        },
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: CustomFooter(
        onTap: (index) {
          // Navigation logic is handled in CustomFooter
        },
      ),
    );
  }
}
