import 'package:flutter/material.dart';
import 'package:hedieaty_application/models/user_model.dart';
import '../widgets/custom_header.dart';
import '../widgets/custom_footer.dart';
import '../widgets/friend_card_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../views/friend_event_list_view.dart';
import '../services/firestore_notification_listener.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;
  String searchQuery = '';
  Stream<List<Map<String, dynamic>>> _fetchFriends() {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('friends')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final friendData = doc.data();
              friendData['id'] = doc.id; // Include the Firestore document ID
              return friendData;
            }).toList());
  }

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirestoreNotificationListener.listenForNotifications(user.uid);
    }
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
      key: const Key('home_view_scaffold'),
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
        key: const Key('home_view_body'),
        children: [
          // Create Event/List Button
          Padding(
            key: const Key('create_event_button'),
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/events');
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Create Your Own Event/List',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          // Search Bar
          Padding(
            key: const Key('home_search_bar'),
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              key: const Key('search_text_field'),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.trim().toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search friends',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          // Friends List
          Expanded(
            key: const Key('friends_list_view'),
            child: StreamBuilder(
              stream: _fetchFriends(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    key: Key('friends_list_loading'),
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasError) {
                  return const Center(
                    key: Key('friends_list_error'),
                    child: Text('Error fetching data.'),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    key: Key('no_friends_found'),
                    child: Text('No friends found.'),
                  );
                }

                final friends = snapshot.data! as List<Map<String, dynamic>>;
                final filteredFriends = friends.where((friend) {
                  final name = friend['name'].toString().toLowerCase();
                  return name.contains(searchQuery);
                }).toList();

                return ListView.builder(
                  key: const Key('filtered_friends_list_view'),
                  itemCount: filteredFriends.length,
                  itemBuilder: (context, index) {
                    final friend = filteredFriends[index];
                    return FriendCardWidget(
                      key: Key('friend_card_$index'),
                      name: friend['name'],
                      profileImage: friend['imageUrl'] ??
                          'assets/images/default_profile.jpg',
                      upcomingEvents: 0,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                FriendEventListView(friendId: friend['id']),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('add_friend_fab'),
        onPressed: () {
          _showAddFriendDialog(context);
        },
        backgroundColor: Colors.orange,
        child: const Icon(Icons.person_add),
      ),
      bottomNavigationBar: CustomFooter(
        key: const Key('home_footer_navigation'),
        onTap: (index) {
          // Navigation logic
        },
      ),
    );
  }
}
