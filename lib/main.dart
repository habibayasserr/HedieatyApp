import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'views/auth_view.dart'; // Make sure this path is correct!

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hedieaty',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AuthView(),
    );
  }
}
