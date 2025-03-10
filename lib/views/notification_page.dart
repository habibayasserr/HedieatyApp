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
      key: const Key('notification_page_scaffold'),
      appBar: AppBar(
        key: const Key('notification_page_app_bar'),
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF005F73), // Theme color
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        key: const Key('notifications_stream_builder'),
        stream: _fetchNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              key: Key('notifications_loading'),
              child: CircularProgressIndicator(color: Color(0xFF005F73)),
            );
          }
          if (snapshot.hasError) {
            return const Center(
              key: Key('notifications_error'),
              child: Text(
                'Error fetching notifications.',
                style: TextStyle(color: Color(0xFFEF0F72)), // Deep pink
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              key: Key('notifications_empty'),
              child: Text(
                'No notifications.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          final notifications = snapshot.data!;
          return ListView.builder(
            key: const Key('notifications_list_view'),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              final timestamp = notification['timestamp'] != null
                  ? (notification['timestamp'] as DateTime)
                  : null;

              return Card(
                key: Key('notification_card_$index'),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: const Color(0xFF005F73), width: 2),
                ),
                elevation: 2,
                child: ListTile(
                  title: Text(
                    notification['message'],
                    key: Key('notification_message_$index'),
                    style: const TextStyle(
                      color: Color(0xFF005F73),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: timestamp != null
                      ? Text(
                          'Received: ${timestamp.toLocal()}'.split('.').first,
                          key: Key('notification_timestamp_$index'),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
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
