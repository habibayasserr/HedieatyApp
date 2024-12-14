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
      'profileImage': 'assets/images/alice.jpg',
      'upcomingEvents': 2,
      'phone': '123-456-7890'
    },
    {
      'name': 'Bob Smith',
      'profileImage': 'assets/images/bob.jpg',
      'upcomingEvents': 0,
      'phone': '987-654-3210'
    },
  ];

  List<Map<String, dynamic>> filteredFriends = [];

  @override
  void initState() {
    super.initState();
    filteredFriends = friends; // Initialize with all friends
  }

  void _addFriend(String name, String phone) {
    setState(() {
      friends.add({
        'name': name,
        'profileImage': 'assets/images/default_profile.jpg', // Default image
        'upcomingEvents': 0,
        'phone': phone,
      });
      filteredFriends = friends; // Refresh filtered list
    });
  }

  void _showAddFriendDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Friend'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Friend Name',
                    hintText: 'Enter friend\'s name',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    hintText: 'Enter phone number',
                  ),
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
                final phone = phoneController.text.trim();

                if (name.isNotEmpty && phone.isNotEmpty) {
                  _addFriend(name, phone);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill in all fields'),
                    ),
                  );
                }
              },
              child: const Text('Add'),
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
        title: 'Hedieaty',
        onProfileTap: () {
          // Navigate to Profile
        },
        onNotificationTap: () {
          // Navigate to Notifications
        },
      ),
      body: Column(
        children: [
          // Create Event/List Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: () {
                // Navigate to the Create Event/List page
                //Navigator.pushNamed(
                //context, '/create-event'); // Placeholder route
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Create Your Own Event/List',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9800),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
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
                hintText: 'Search friends\' gift lists',
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddFriendDialog(context);
        },
        backgroundColor: Colors.orange,
        child: const Icon(Icons.person_add),
      ),
      bottomNavigationBar: CustomFooter(
        currentIndex: 0,
        onTap: (index) {
          // Handle Footer Navigation
        },
      ),
    );
  }
}
