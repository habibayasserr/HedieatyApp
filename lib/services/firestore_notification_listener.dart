import 'package:cloud_firestore/cloud_firestore.dart';
import 'notification_service.dart';

class FirestoreNotificationListener {
  static void listenForNotifications(String userId) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      for (var docChange in snapshot.docChanges) {
        if (docChange.type == DocumentChangeType.added) {
          final notificationData = docChange.doc.data();
          if (notificationData != null) {
            NotificationService.showNotification(
              title: 'Gift Notification',
              body:
                  notificationData['message'] ?? 'You have a new notification',
            );
          }
        }
      }
    });
  }
}
