import 'package:flutter/material.dart';

class CustomFooter extends StatelessWidget {
  final int currentIndex; // The current active tab index
  // Optional callbacks for navigation (commented for static implementation)
  final Function(int)? onTap;

  const CustomFooter({
    Key? key,
    required this.currentIndex,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        // Uncomment to enable navigation logic
        // if (onTap != null) onTap!(index);
      },
      backgroundColor: Colors.white,
      selectedItemColor: Colors.orange, // Highlight the active tab
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today), // Events Icon (left)
          label: 'Events',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home), // Home Icon (center)
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person), // Profile Icon (right)
          label: 'Profile',
        ),
      ],
    );
  }
}
