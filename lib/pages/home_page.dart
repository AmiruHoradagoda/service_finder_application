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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _searchQuery = ""; // Clear search when switching tabs
    });
  }

  void _onLocationChanged(String? value) {
    setState(() {
      _selectedLocation = value;
    });
  }

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
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 2,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search TextField with enhanced styling
                Container(
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
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Search posts...",
                      prefixIcon: const Icon(Icons.search),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12.0, horizontal: 16.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          // Styled DropdownButton
          Container(
            margin: const EdgeInsets.only(right: 16.0),
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: DropdownButton<String>(
              value: _selectedLocation,
              hint: const Text('Location'),
              icon: const Icon(Icons.location_on),
              underline: const SizedBox(),
              items: [
                'Clear Location',
                ...locations,
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
                    _selectedLocation = null;
                  });
                } else {
                  _onLocationChanged(value);
                }
              },
            ),
          ),
        ],
      ),
      drawer: const MyDrawer(),
      body: Column(
        children: [
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _selectedIndex == 0
                  ? ProvidersPostList(
                      key: const ValueKey(0),
                      database: widget.database,
                      searchQuery: _searchQuery,
                      selectedLocation: _selectedLocation,
                    )
                  : AskForServicePostList(
                      key: const ValueKey(1),
                      database: widget.database,
                      searchQuery: _searchQuery,
                      selectedLocation: _selectedLocation,
                    ),
            ),
          ),
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
          selectedItemColor: Colors.blue.shade900,
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
          backgroundColor: Theme.of(context).colorScheme.background,
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }
}
