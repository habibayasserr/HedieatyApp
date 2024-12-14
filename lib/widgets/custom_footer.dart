import 'package:flutter/material.dart';

class CustomFooter extends StatelessWidget {
  final int currentIndex; // The active tab index
  final Function(int)? onTap; // Optional callback for navigation

  const CustomFooter({
    Key? key,
    required this.currentIndex,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex, // Highlight the active tab
      onTap: (index) {
        // Static implementation: Uncomment when navigation logic is ready
        if (onTap != null) onTap!(index);
      },
      backgroundColor: Colors.white,
      selectedItemColor: Colors.orange, // Highlight active tab
      unselectedItemColor: Colors.grey,
      elevation: 8,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today), // Events Tab
          label: 'Events',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home), // Home Tab
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person), // Profile Tab
          label: 'Profile',
        ),
      ],
    );
  }
}
