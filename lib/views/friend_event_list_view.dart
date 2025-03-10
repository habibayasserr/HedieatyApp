import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/event_model.dart';
import '../widgets/custom_header.dart';
import '../widgets/custom_footer.dart';
import 'friend_gift_list_view.dart';

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
                  key: const Key('friend_events_list_view'),
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return Card(
                      key: Key('friend_event_card_$index'),
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      child: Row(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: const Color(
                                  0xFF005F73), // Dark blue background for date
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                bottomLeft: Radius.circular(12),
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  DateFormat('dd').format(event.date),
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  DateFormat('MMM')
                                      .format(event.date)
                                      .toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
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
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    event.name,
                                    key: Key('friend_event_name_$index'),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Category: ${event.category}',
                                    key: Key('friend_event_details_$index'),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.info_outline,
                              color: Color(0xFFef0c70),
                            ),
                            onPressed: () {
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                          foregroundColor:
                                              const Color(0xFF005F73),
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
                                                  FriendGiftListView(
                                                eventId: event.id!,
                                                friendId: widget.friendId,
                                              ),
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
                          ),
                        ],
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
