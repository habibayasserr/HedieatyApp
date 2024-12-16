import 'package:flutter/material.dart';

class CustomFooter extends StatelessWidget {
  final Function(int) onTap;

  const CustomFooter({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the current route name dynamically
    final String? currentRoute = ModalRoute.of(context)?.settings.name;

    // Determine the current index based on the route
    int currentIndex;
    switch (currentRoute) {
      case '/home':
        currentIndex = 1; // Home tab
        break;
      case '/events':
        currentIndex = 0; // Events tab
        break;
      /* case '/profile':
        currentIndex = 2; // Profile tab
        break;
        */
      default:
        currentIndex = 1; // Default to Home tab
    }

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        if (index != currentIndex) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/events'); // Navigate to Events
              break;
            case 1:
              Navigator.pushNamed(context, '/home'); // Navigate to Home
              break;
            case 2:
              Navigator.pushNamed(context, '/profile'); // Navigate to Profile
              break;
          }
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.event),
          label: 'Events',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}
