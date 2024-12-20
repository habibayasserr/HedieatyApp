import 'package:flutter/material.dart';
import 'views/home_view.dart';
import 'views/event_list_view.dart';
import 'views/sign_in_view.dart';
import 'views/sign_up_view.dart';
import 'views/profile_view.dart';
import 'views/splash_view.dart';
import 'views/pledged_gifts_view.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      '/home': (context) => const HomeView(), // Home Screen
      '/events': (context) => const EventListView(), // Event List Page
      '/signin': (context) => SignInView(),
      '/signup': (context) => SignUpView(),
      '/profile': (context) => const ProfileView(),
      '/splash': (context) => const SplashView(),
      '/pledged': (context) => const MyPledgedGiftsView(),
      // '/notifications': (context) => const NotificationsView(),
    };
  }
}
