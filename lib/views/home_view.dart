import 'package:flutter/material.dart';
import '../widgets/custom_header.dart';
import '../widgets/custom_footer.dart';
import '../widgets/friend_card_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;
  List<Map<String, dynamic>> filteredFriends = [];
  Future<void> _fetchFriends() async {
    if (_userId == null) return;
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('friends')
          .get();
      setState(() {
        filteredFriends = querySnapshot.docs.map((doc) {
          return {
            'name': doc['name'],
            'phone': doc['phone'],
            'profileImage':
                'assets/images/default_profile.jpg', // Default for now
            'upcomingEvents': 0, // Placeholder for now
          };
        }).toList();
      });
    } catch (e) {
      print('Error fetching friends: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchFriends();
  }

  Future<void> _addFriend(String name, String phone) async {
    if (_userId == null) return;

    try {
      // Check if friend exists in Firestore
      final querySnapshot = await _firestore
          .collection('users')
          .where('phone', isEqualTo: phone)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Friend not found.')),
        );
        return;
      }

      final friendDoc = querySnapshot.docs.first;
      final friendId = friendDoc.id;

      // Add friend to current user's 'friends' subcollection
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('friends')
          .doc(friendId)
          .set({
        'friend_id': friendId,
        'name': friendDoc['name'],
        'phone': friendDoc['phone'],
      });

      // Add current user to the other user's 'friends' subcollection
      await _firestore
          .collection('users')
          .doc(friendId)
          .collection('friends')
          .doc(_userId)
          .set({
        'friend_id': _userId,
        'name': FirebaseAuth.instance.currentUser?.displayName ?? 'Unknown',
        'phone': FirebaseAuth.instance.currentUser?.phoneNumber ?? 'Unknown',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Friend added successfully!')),
      );

      _fetchFriends(); // Refresh the friends list
    } catch (e) {
      print('Error adding friend: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add friend.')),
      );
    }
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
                    const SnackBar(content: Text('Please fill in all fields')),
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
                Navigator.pushNamed(context, '/events'); // Placeholder route
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
                  filteredFriends = filteredFriends.where((friend) {
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
        onTap: (index) {
          // Navigation logic is handled in CustomFooter
        },
      ),
    );
  }
}
