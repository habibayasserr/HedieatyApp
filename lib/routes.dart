import 'package:flutter/material.dart';
import 'views/home_view.dart';
import 'views/event_list_view.dart';
import 'views/sign_in_view.dart';
import 'views/sign_up_view.dart';

// Import additional screens as you implement them

class AppRoutes {
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      '/home': (context) => const HomeView(), // Home Screen
      '/events': (context) => const EventListView(), // Event List Page
      '/signin': (context) => SignInView(),
      '/signup': (context) => SignUpView(),
      // Add more routes here as you implement new screens
      // '/profile': (context) => const ProfileView(),
      // '/notifications': (context) => const NotificationsView(),
    };
  }
}
