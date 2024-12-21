import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:hedieaty_application/models/user_model.dart';
import '../widgets/custom_header.dart';
import '../widgets/custom_footer.dart';
import '../widgets/friend_card_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../views/friend_event_list_view.dart';
import '../services/firestore_notification_listener.dart';

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
              friendData['id'] = doc.id;
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

  void _showAddFriendDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.white,
          title: Text(
            'Add Friend',
            style: TextStyle(
              color: const Color(0xFF005F73),
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Friend Name',
                    labelStyle: TextStyle(color: const Color(0xFF005F73)),
                    hintText: 'Enter friend\'s name',
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: const Color(0xFF005F73), width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: const Color(0xFF005F73), width: 1),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    labelStyle: TextStyle(color: const Color(0xFF005F73)),
                    hintText: 'Enter phone number',
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: const Color(0xFF005F73), width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: const Color(0xFF005F73), width: 1),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF005F73),
              ),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final phone = phoneController.text.trim();

                if (name.isNotEmpty && phone.isNotEmpty) {
                  Navigator.pop(context);
                  // Call friend addition logic here
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill in all fields')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFDE9F2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));

    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        return Scaffold(
          key: const Key('home_view_scaffold'),
          backgroundColor: Colors.white, // Set background to white
          appBar: CustomHeader(
            title: 'Hedieaty',
            onProfileTap: () {},
            onNotificationTap: () {},
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              key: const Key('home_view_body'),
              children: [
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/events');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white, // Neutral white background
                      side: BorderSide(
                          color: const Color(0xFF005F73),
                          width: 2), // Darker blue outline
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 24),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.calendar_today,
                            color: Color(0xFF005F73)), // Darker blue icon
                        SizedBox(width: 8),
                        Text(
                          'Create Event/List',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF005F73), // Darker blue text
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Flexible(
                  child: TextField(
                    key: const Key('search_text_field'),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value.trim().toLowerCase();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search for friends',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white, // Neutral white background
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: const Color(0xFF005F73), // Darker blue outline
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
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

                      final friends =
                          snapshot.data! as List<Map<String, dynamic>>;
                      final filteredFriends = friends.where((friend) {
                        final name = friend['name'].toString().toLowerCase();
                        return name.contains(searchQuery);
                      }).toList();

                      return ListView.separated(
                        key: const Key('filtered_friends_list_view'),
                        itemCount: filteredFriends.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
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
                                  builder: (context) => FriendEventListView(
                                      friendId: friend['id']),
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
          ),
          floatingActionButton: Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              border: Border.all(
                  color: const Color(0xFF005F73),
                  width: 2), // Darker blue outline
              color: Colors.white, // White background
              borderRadius:
                  BorderRadius.circular(12), // Square with rounded corners
            ),
            child: IconButton(
              key: const Key('add_friend_fab'),
              icon: const Icon(Icons.person_add,
                  color: Color(0xFFEF0F72), size: 28), // Magenta icon
              onPressed: () {
                _showAddFriendDialog(context);
              },
            ),
          ),
          bottomNavigationBar: CustomFooter(
            key: const Key('home_footer_navigation'),
            onTap: (index) {},
          ),
        );
      },
    );
  }
}
