import 'package:flutter/material.dart';
import 'views/home_view.dart'; // Ensure the path matches your project structure

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Hides the debug banner
      title: 'Hedieaty',
      theme: ThemeData(
        primarySwatch: Colors.orange, // Sets a primary theme color
      ),
      home: const HomeView(), // Sets HomeView as the initial page
    );
  }
}
