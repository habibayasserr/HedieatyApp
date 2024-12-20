import 'package:flutter/material.dart';
import 'routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/notification_service.dart';
import 'services/firestore_notification_listener.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Try initializing Firebase and handle errors gracefully
  try {
    await Firebase.initializeApp();
    await NotificationService.initialize(); // Initialize local notifications
    print('Firebase initialized successfully');
  } catch (e) {
    print('Error initializing Firebase: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    // Ensure FirebaseAuth is initialized AFTER Firebase.initializeApp()
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        FirestoreNotificationListener.listenForNotifications(userId);
        print('Listening for notifications for user $userId');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hedieaty',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      initialRoute: '/splash',
      routes: AppRoutes.getRoutes(),
    );
  }
}
