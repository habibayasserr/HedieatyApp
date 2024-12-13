import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'views/firestore_test_view.dart';

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
      home: FirestoreTestView(), // Switch to FirestoreTestView
    );
  }
}
