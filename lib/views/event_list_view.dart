import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/event_model.dart';
import '../widgets/custom_header.dart';
import '../widgets/custom_footer.dart';
import '../views/gift_list_view.dart';
import '../viewmodels/event_list_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EventListView extends StatefulWidget {
  const EventListView({Key? key}) : super(key: key);

  @override
  _EventListViewState createState() => _EventListViewState();
}

class _EventListViewState extends State<EventListView> {
  List<Event> events = [];
  final EventListViewModel _viewModel = EventListViewModel();
  late Future<List<Event>> _eventsFuture;
  String selectedSortOption = 'Sort by Name (Ascending)';

  @override
  void initState() {
    super.initState();
    _loadEvents();
    _eventsFuture = _viewModel.getAllEvents();
  }

  // Fetch events from the local database

  Future<void> _loadEvents() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final fetchedEvents = await _viewModel.getAllEventsForUser(userId);
    setState(() {
      events = fetchedEvents;
    });
  }

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
  List<Event> _sortEvents(List<Event> events) {
    switch (selectedSortOption) {
      case 'Sort by Name (Ascending)':
        events.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'Sort by Name (Descending)':
        events.sort((a, b) => b.name.compareTo(a.name));
        break;
      case 'Sort by Upcoming Events':
        events.sort((a, b) =>
            _calculateStatus(a.date).compareTo(_calculateStatus(b.date)));
        break;
      case 'Sort by Past Events':
        events.sort((a, b) =>
            _calculateStatus(b.date).compareTo(_calculateStatus(a.date)));
        break;

      case 'Sort by Category':
        events.sort((a, b) => a.category.compareTo(b.category));
        break;
    }
    return events;
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
                      selectedCategory = value;
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
                      style: const TextStyle(fontWeight: FontWeight.bold),
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

                final loggedInUserId = FirebaseAuth.instance.currentUser?.uid;
                if (loggedInUserId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Unable to add event. Please log in again.')),
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
                      userId: loggedInUserId, // Pass the logged-in user's ID
                    ));
                  });
                } else {
                  // Update existing event
                  setState(() {
                    events[index!] = Event(
                      id: event.id,
                      name: name,
                      category: selectedCategory,
                      date: selectedDate ?? event.date,
                      location: location,
                      description: description,
                      userId: event.userId, // Keep the existing user ID
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomHeader(
        title: 'Events',
        onProfileTap: () {},
        onNotificationTap: () {},
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: selectedSortOption,
              items: [
                'Sort by Name (Ascending)',
                'Sort by Name (Descending)',
                'Sort by Upcoming Events',
                'Sort by Past Events',
                'Sort by Category',
              ].map((sortOption) {
                return DropdownMenuItem(
                  value: sortOption,
                  child: Text(sortOption),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => selectedSortOption = value!);
              },
              isExpanded: true,
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Event>>(
              future: _eventsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No events available.'));
                }

                final sortedEvents = _sortEvents(snapshot.data!);

                return ListView.builder(
                  itemCount: sortedEvents.length,
                  itemBuilder: (context, index) {
                    final event = sortedEvents[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(event.name),
                        subtitle: Text(
                            'Date: ${DateFormat('yyyy-MM-dd').format(event.date)}\n'
                            'Location: ${event.location}\n'
                            'Category: ${event.category}'),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GiftListView(event: event),
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showEventDialog(event: event),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final confirmDelete = await showDialog<bool>(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text('Delete Event'),
                                      content: const Text(
                                          'Are you sure you want to delete this event?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text('Delete',
                                              style:
                                                  TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    );
                                  },
                                );

                                if (confirmDelete == true) {
                                  await _viewModel.deleteEvent(event.id!);
                                  _loadEvents();
                                }
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
        onPressed: () => _showEventDialog(),
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: CustomFooter(onTap: (index) {}),
    );
  }
}
