import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  static void initService() {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    _firestore.collection('notifications').snapshots().listen((snapshot) {
      print("Notification");
    });
  }
}
