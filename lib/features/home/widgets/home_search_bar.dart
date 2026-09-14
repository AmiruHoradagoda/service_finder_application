import 'package:flutter/material.dart';
import 'package:service_finder_application/core/constants/locations.dart';

class HomeSearchBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeSearchBar(
      {super.key,
      required this.onSearchChanged,
      required this.onLocationChanged});
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String?> onLocationChanged;
  @override
  Size get preferredSize => const Size.fromHeight(75.0);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Search TextField with enhanced styling
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(30.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                onChanged: onSearchChanged,
                decoration: const InputDecoration(
                  hintText: "Search posts...",
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 12.0, horizontal: 14.0),
                ),
              ),
            ),
          ),
          // Icon-only popup button for location with custom direction
          Container(
            margin: const EdgeInsets.only(left: 8.0),
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: PopupMenuButton<String>(
              icon: const Icon(
                Icons.location_on,
                size: 24, // Icon size
              ),
              iconSize: 24, // Adjust icon size here
              onSelected: (value) =>
                  onLocationChanged(value == 'Clear Location' ? null : value),
              itemBuilder: (BuildContext context) {
                return [
                  const PopupMenuItem<String>(
                    value: 'Clear Location',
                    child: Text('Clear Location'),
                  ),
                  ...locations.map((location) {
                    return PopupMenuItem<String>(
                      value: location,
                      child: Text(location),
                    );
                  }),
                ];
              },
              offset: const Offset(0, 50), // Custom dropdown position
            ),
          ),
        ],
      ),
    );
  }
}
