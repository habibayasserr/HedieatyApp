import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationPage extends StatelessWidget {
  final String userId; // Current user ID

  const NotificationPage({Key? key, required this.userId}) : super(key: key);

  // Fetch notifications for the user
  Stream<List<Map<String, dynamic>>> _fetchNotifications() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  'message': doc['message'],
                  'timestamp': doc['timestamp']?.toDate(),
                })
            .toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.orange,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _fetchNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching notifications.'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No notifications.'));
          }

          final notifications = snapshot.data!;
          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              final timestamp = notification['timestamp'] != null
                  ? (notification['timestamp'] as DateTime)
                  : null;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(notification['message']),
                  subtitle: timestamp != null
                      ? Text(
                          'Received: ${timestamp.toLocal()}',
                          style: const TextStyle(color: Colors.grey),
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
