import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/event_model.dart';

class EventListView extends StatefulWidget {
  const EventListView({Key? key}) : super(key: key);

  @override
  _EventListViewState createState() => _EventListViewState();
}

class _EventListViewState extends State<EventListView> {
  // List of events
  final List<Event> events = [
    Event(
      name: 'Alice\'s Birthday',
      date: DateTime.now().add(const Duration(days: 10)),
      location: 'Alice\'s House',
      description: 'A fun birthday party with friends and family.',
    ),
    Event(
      name: 'Bob\'s Wedding',
      date: DateTime.now().add(const Duration(days: 20)),
      location: 'Central Park',
      description: 'A beautiful outdoor wedding.',
    ),
  ];

  // Sorting criteria
  String selectedSortOption = 'Name (Ascending)';

  void _showEventDialog({Event? event, int? index}) {
    final TextEditingController nameController =
        TextEditingController(text: event?.name);
    final TextEditingController locationController =
        TextEditingController(text: event?.location);
    final TextEditingController descriptionController =
        TextEditingController(text: event?.description);
    DateTime? selectedDate = event?.date;

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
                          ? DateFormat('dd-MM-yyyy')
                              .format(selectedDate!) // Format Date
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
              onPressed: () => Navigator.pop(context), // Close dialog
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
                      date: selectedDate ?? DateTime.now(),
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
  }

  void _sortEvents() {
    switch (selectedSortOption) {
      case 'Name (Ascending)':
        events.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'Name (Descending)':
        events.sort((a, b) => b.name.compareTo(a.name));
        break;
      case 'Date (Upcoming First)':
        events.sort((a, b) => a.date.compareTo(b.date));
        break;
      case 'Date (Past First)':
        events.sort((a, b) => b.date.compareTo(a.date));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      body: Column(
        children: [
          // Sorting Dropdown
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: selectedSortOption,
              items: [
                'Name (Ascending)',
                'Name (Descending)',
                'Date (Upcoming First)',
                'Date (Past First)',
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
                    _sortEvents(); // Apply sorting
                  });
                }
              },
              isExpanded: true,
            ),
          ),
          // Event List
          Expanded(
            child: ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(event.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Date: ${DateFormat('yyyy-MM-dd').format(event.date)}'),
                        Text('Location: ${event.location}'),
                        Text('Description: ${event.description}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () =>
                              _showEventDialog(event: event, index: index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              events.removeAt(index);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
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
    );
  }
}
