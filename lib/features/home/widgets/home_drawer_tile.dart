import 'package:flutter/material.dart';

class HomeDrawerTile extends StatelessWidget {
  const HomeDrawerTile(
      {super.key,
      required this.icon,
      required this.title,
      required this.onTap});
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 25.0),
      child: ListTile(
        leading: Icon(
          icon,
          color: Theme.of(context)
              .colorScheme
              .secondary, // Dynamic secondary icon color
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.color, // Updated text color for bodyLarge
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
