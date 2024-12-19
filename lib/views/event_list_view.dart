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

  /* void _showEventDialog({Event? event, int? index}) {
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
              onPressed: () {
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

                if (event == null) {
                  // Add new event
                  setState(() {
                    events.add(Event(
                      name: name,
                      category: selectedCategory,
                      date: selectedDate ?? DateTime.now(),
                      location: location,
                      description: description,
                    ));
                  });
                } else {
                  // Update existing event
                  setState(() {
                    events[index!] = Event(
                      name: name,
                      category: selectedCategory,
                      date: selectedDate ?? event.date,
                      location: location,
                      description: description,
                    );
                  });
                }

                Navigator.pop(context); // Close dialog
              },
              child: Text(event == null ? 'Add' : 'Save'),
            ),
          ],
        );
      },
    );
  } */

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
          // Sorting Dropdown
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
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
          // Event List
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
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(event.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'Date: ${DateFormat('yyyy-MM-dd').format(event.date)}'),
                            Text('Location: ${event.location}'),
                            Text('Category: ${event.category}'),
                          ],
                        ),
                        onTap: () {
                          // Navigate to GiftListView when the card is tapped
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GiftListView(event: event),
                            ),
                          );
                        },
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                // Handle event editing here
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                // Handle event deletion here
                              },
                            ),
                          ],
                        ),
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
