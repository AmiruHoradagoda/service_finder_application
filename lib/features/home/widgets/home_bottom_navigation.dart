import 'package:flutter/material.dart';

class HomeBottomNavigation extends StatelessWidget {
  const HomeBottomNavigation(
      {super.key, required this.selectedIndex, required this.onTap});
  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Providers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.help),
            label: 'Ask for Service',
          ),
        ],
        currentIndex: selectedIndex,
        selectedItemColor: Colors.blue.shade900,
        unselectedItemColor: Colors.grey,
        onTap: onTap,
        backgroundColor: Theme.of(context).colorScheme.surface,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
