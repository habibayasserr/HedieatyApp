import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/event_model.dart';
import '../widgets/custom_header.dart';
import '../widgets/custom_footer.dart';
//import 'friend_gift_list_view.dart';

class FriendEventListView extends StatefulWidget {
  final String friendId; // Friend's user ID

  const FriendEventListView({Key? key, required this.friendId})
      : super(key: key);

  @override
  _FriendEventListViewState createState() => _FriendEventListViewState();
}

class _FriendEventListViewState extends State<FriendEventListView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String selectedSortOption = 'Sort by Name (Ascending)';

  // Fetch events for the friend
  Stream<List<Event>> _fetchFriendEvents() {
    return _firestore
        .collection('users')
        .doc(widget.friendId)
        .collection('events')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return Event.fromJson(doc.data(), doc.id);
            }).toList());
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomHeader(
        title: "Friend's Events",
        onProfileTap: () {
          Navigator.pushNamed(context, '/profile');
        },
        onNotificationTap: () {
          Navigator.pushNamed(context, '/notifications');
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
              stream: _fetchFriendEvents(),
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
                                'Date: ${DateFormat('dd-MM-yyyy').format(event.date)}'),
                            Text('Location: ${event.location}'),
                            Text('Category: ${event.category}'),
                          ],
                        ),
                        onTap: () {
                          // Navigate to Friend's Gift List
                          /* Navigator.push(
                           context,
                            MaterialPageRoute(
                              builder: (context) => FriendGiftListView(
                                eventId: event.id!,
                                friendId: widget.friendId,
                              ),
                            ),
                          );*/
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
      bottomNavigationBar: CustomFooter(
        onTap: (index) {},
      ),
    );
  }
}
