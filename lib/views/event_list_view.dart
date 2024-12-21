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
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    try {
      // Get all gifts in the subcollection
      final giftsSnapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('events')
          .doc(eventId)
          .collection('gifts')
          .get();

      // Delete each gift document
      for (final doc in giftsSnapshot.docs) {
        await doc.reference.delete();
      }

      // Finally, delete the event document
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('events')
          .doc(eventId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Event and its gifts deleted successfully!')),
      );
    } catch (e) {
      print('Error deleting event: $e');
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
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event == null ? 'Add Event' : 'Edit Event',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF005F73),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Event Name',
                    hintText: 'Enter event name',
                    filled: true,
                    fillColor: const Color(0xFFE5F8FF),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: const Color(0xFF005F73)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (var category in [
                      'Birthday',
                      'Wedding',
                      'Graduation',
                      'Holiday',
                      'Engagement',
                      'Anniversary',
                      'Other'
                    ])
                      ChoiceChip(
                        label: Text(category),
                        selected: selectedCategory == category,
                        onSelected: (isSelected) {
                          setState(() {
                            selectedCategory = category;
                          });
                        },
                        selectedColor: const Color(0xFFEF0F72),
                        backgroundColor: const Color(0xFF0077B6),
                        labelStyle: TextStyle(
                          color: selectedCategory == category
                              ? Colors.white
                              : Colors.white,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: locationController,
                  decoration: InputDecoration(
                    labelText: 'Location',
                    hintText: 'Enter event location',
                    filled: true,
                    fillColor: const Color(0xFFE5F8FF),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: const Color(0xFF005F73)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    hintText: 'Enter event description',
                    filled: true,
                    fillColor: const Color(0xFFE5F8FF),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: const Color(0xFF005F73)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text(
                      'Date:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF005F73),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        selectedDate != null
                            ? DateFormat('dd-MM-yyyy').format(selectedDate!)
                            : 'Select Date',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.calendar_today,
                          color: Color(0xFFEF0F72)),
                      onPressed: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: Color(0xFF005F73),
                                  onPrimary: Colors.white,
                                  onSurface: Colors.black,
                                ),
                              ),
                              child: child!,
                            );
                          },
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
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF005F73),
                      ),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final name = nameController.text.trim();
                        final location = locationController.text.trim();
                        final description = descriptionController.text.trim();

                        if (name.isEmpty ||
                            location.isEmpty ||
                            description.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please fill in all fields'),
                            ),
                          );
                          return;
                        }

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

                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF0F72),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
          // Sorting Dropdown
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0XFFFDE9F2), // Light blue background
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF005F73), // Darker blue border
                  width: 2,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButtonHideUnderline(
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
                      child: Text(
                        sortOption,
                        style: const TextStyle(
                          color: Color(0xFF005F73), // Darker blue text
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
                  dropdownColor:
                      const Color(0XFFFDE9F2), // Dropdown background color
                  icon: const Icon(
                    Icons.arrow_drop_down,
                    color: Color(0xFF005F73),
                    size: 36, // Darker blue icon
                  ),
                ),
              ),
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
                        title: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 80,
                              decoration: BoxDecoration(
                                color: const Color(
                                    0xFF005F73), // Dark blue background for date
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    DateFormat('dd').format(event.date),
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    DateFormat('MMM')
                                        .format(event.date)
                                        .toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    DateFormat('yyyy').format(event.date),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    event.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Category: ${event.category}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          // Show dialog with event details
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                title: Text(
                                  event.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF005F73),
                                  ),
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Location: ${event.location}',
                                      style: const TextStyle(
                                        color: Color(0xFF005F73),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Description:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF005F73),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      event.description,
                                      style: const TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    style: TextButton.styleFrom(
                                      foregroundColor: const Color(0xFF005F73),
                                    ),
                                    child: const Text('Close'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(
                                          context); // Close the dialog
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              GiftListView(event: event),
                                        ),
                                      );
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor: const Color(
                                          0xFFEF0F72), // Deep pink for View Gifts
                                    ),
                                    child: const Text('View Gifts'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit,
                                  color:
                                      Color(0xFF005F73)), // Dark blue for edit
                              onPressed: () {
                                _showEventDialog(event: event);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Color(
                                      0xFFEF0F72)), // Deep pink for delete
                              onPressed: () async {
                                final shouldDelete = await showDialog<bool>(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      title: const Text(
                                        'Confirm Deletion',
                                        style: TextStyle(
                                          color: Color(0xFF005F73),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      content: const Text(
                                        'Are you sure you want to delete this event?',
                                        style: TextStyle(
                                          color: Colors.black,
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(
                                              context, false), // Cancel
                                          style: TextButton.styleFrom(
                                            foregroundColor:
                                                const Color(0xFF005F73),
                                          ),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.pop(
                                              context, true), // Confirm
                                          style: TextButton.styleFrom(
                                            foregroundColor:
                                                const Color(0xFFEF0F72),
                                          ),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    );
                                  },
                                );

                                if (shouldDelete == true) {
                                  try {
                                    await _firestore
                                        .collection('users')
                                        .doc(_userId)
                                        .collection('events')
                                        .doc(event.id)
                                        .delete();

                                    final rootContext =
                                        ScaffoldMessenger.of(context);
                                    rootContext.showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Event deleted successfully!')),
                                    );
                                  } catch (e) {
                                    final rootContext =
                                        ScaffoldMessenger.of(context);
                                    rootContext.showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text('Failed to delete event.')),
                                    );
                                    print('Error deleting event: $e');
                                  }
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
        onPressed: () {
          _showEventDialog();
        },
        backgroundColor: const Color(0xFFEF0F72),
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
