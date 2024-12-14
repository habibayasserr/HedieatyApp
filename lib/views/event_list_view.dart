import 'package:flutter/material.dart';
import '../models/event_model.dart';

class EventListView extends StatefulWidget {
  const EventListView({Key? key}) : super(key: key);

  @override
  _EventListViewState createState() => _EventListViewState();
}

class _EventListViewState extends State<EventListView> {
  // Placeholder list of events
  final List<Event> events = [
    Event(name: 'Alice\'s Birthday', category: 'Birthday', status: 'Upcoming'),
    Event(name: 'Bob\'s Wedding', category: 'Wedding', status: 'Current'),
    Event(name: 'Project Graduation', category: 'Graduation', status: 'Past'),
  ];

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
          // Sort and Filter Options
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  hint: const Text('Sort by'),
                  items: ['Name', 'Category', 'Status']
                      .map((sortOption) => DropdownMenuItem(
                            value: sortOption,
                            child: Text(sortOption),
                          ))
                      .toList(),
                  onChanged: (value) {
                    // Handle sorting logic here
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    // Open Add Event dialog
                  },
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  child: const Text('Add Event'),
                ),
              ],
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
                    subtitle: Text('${event.category} - ${event.status}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            // Open Edit Event dialog
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              events.removeAt(index); // Remove event
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
    );
  }
}
