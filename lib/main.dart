import 'package:flutter/material.dart';
import 'package:hedieaty_application/services/notification_service.dart';
import 'routes.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
   NotificationService.initService();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hedieaty',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      initialRoute: '/splash', // Starting page
      routes: AppRoutes.getRoutes(), // Add routes here
    );
  }
}
