import 'package:flutter/material.dart';
import 'views/home_view.dart';
import 'views/event_list_view.dart';

// Import additional screens as you implement them

class AppRoutes {
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      '/home': (context) => const HomeView(), // Home Screen
      '/events': (context) => const EventListView(), // Event List Page
      // Add more routes here as you implement new screens
      // '/profile': (context) => const ProfileView(),
      // '/notifications': (context) => const NotificationsView(),
    };
  }
}
