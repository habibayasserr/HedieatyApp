import 'package:flutter/material.dart';
import '../widgets/custom_header.dart';
import '../widgets/custom_footer.dart';
import '../widgets/friend_card_widget.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final List<Map<String, dynamic>> friends = [
    {
      'name': 'Alice Johnson',
      'profileImage': 'assets/images/default_profile.png',
      'upcomingEvents': 2,
    },
    {
      'name': 'Bob Smith',
      'profileImage': 'assets/images/default_profile.png',
      'upcomingEvents': 0,
    },
  ];

  List<Map<String, dynamic>> filteredFriends = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredFriends = friends; // Initialize with all friends
  }

  void _addFriend(String name, String phoneNumber) {
    setState(() {
      friends.add({
        'name': name,
        'profileImage': 'assets/images/default_profile.png',
        'upcomingEvents': 0,
      });
      filteredFriends = friends; // Refresh the filtered list
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomHeader(
        title: 'Upcoming Gift Dates',
        onProfileTap: () {
          // Navigate to Profile
        },
        onNotificationTap: () {
          // Navigate to Notifications
        },
      ),
      body: Column(
        children: [
          // Create Event Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: () {
                // Navigate to Create Event/List
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Your Own Event/List'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() {
                  filteredFriends = friends.where((friend) {
                    return friend['name']
                        .toLowerCase()
                        .contains(value.toLowerCase());
                  }).toList();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search friends...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          // Friends List
          Expanded(
            child: ListView.builder(
              itemCount: filteredFriends.length,
              itemBuilder: (context, index) {
                final friend = filteredFriends[index];
                return FriendCardWidget(
                  name: friend['name'],
                  profileImage: friend['profileImage'],
                  upcomingEvents: friend['upcomingEvents'],
                  onTap: () {
                    // Navigate to Gift List
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomFooter(
        currentIndex: 0,
        onTap: (index) {
          // Handle navigation between Home, Events, Profile
        },
      ),
    );
  }
}
