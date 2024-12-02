import 'package:flutter/material.dart';
import 'package:service_finder_application/components/ask_for_service_post_list.dart';
import 'package:service_finder_application/components/my_drawer.dart';
import 'package:service_finder_application/components/providers_post_list.dart';
import 'package:service_finder_application/database/firestore.dart';
import 'package:service_finder_application/helper/locations.dart'; // Import locations file

class HomePage extends StatefulWidget {
  HomePage({super.key});

  final FirestoreDatabase database = FirestoreDatabase();

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String _searchQuery = "";
  String? _selectedLocation; // Store the selected location

  // Handle the tab change (Providers vs Ask for Service)
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _searchQuery = ""; // Clear search when switching tabs
    });
  }

  // Handle the location change from the dropdown
  void _onLocationChanged(String? value) {
    setState(() {
      _selectedLocation = value; // Update the selected location
    });
  }

  // Method to filter posts based on search and location
  List<Map<String, dynamic>> _filterPosts(List<Map<String, dynamic>> posts) {
    return posts.where((post) {
      final matchesSearch = _searchQuery.isEmpty ||
              post['PostMessage']
                  ?.toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ??
          false;
      final matchesLocation =
          _selectedLocation == null || post['Location'] == _selectedLocation;
      return matchesSearch && matchesLocation;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(
              100.0), // Increased height for both search and dropdown
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search TextField
                TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Search posts...",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                  ),
                ),
                const SizedBox(height: 8),
                // Location Dropdown wrapped in a Container
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Theme.of(context).colorScheme.surface,
                  ),
                  child: DropdownButton<String>(
                    value: _selectedLocation,
                    hint: const Text('Select Location'),
                    isExpanded: true,
                    items: [
                      'Clear Location', // The "Clear Location" option
                      ...locations, // Predefined locations
                    ].map((location) {
                      return DropdownMenuItem<String>(
                        value: location,
                        child: Text(location == 'Clear Location'
                            ? 'Clear Location'
                            : location),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value == 'Clear Location') {
                        setState(() {
                          _selectedLocation =
                              null; // Clear the selected location
                        });
                      } else {
                        _onLocationChanged(
                            value); // Handle regular location change
                      }
                    },
                    underline: const SizedBox(), // Hide the default underline
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      drawer: const MyDrawer(),
      body: Column(
        children: [
          Expanded(
            child: _selectedIndex == 0
                ? ProvidersPostList(
                    database: widget.database,
                    searchQuery: _searchQuery,
                    selectedLocation: _selectedLocation,
                  )
                : AskForServicePostList(
                    database: widget.database,
                    searchQuery: _searchQuery,
                    selectedLocation: _selectedLocation,
                  ),
          )
        ],
      ),
      bottomNavigationBar: SafeArea(
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
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.grey.shade900,
          unselectedItemColor: Theme.of(context).colorScheme.secondary,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
