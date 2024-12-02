import 'package:flutter/material.dart';
import 'package:service_finder_application/components/ask_for_service_post_list.dart';
import 'package:service_finder_application/components/my_drawer.dart';
import 'package:service_finder_application/components/providers_post_list.dart';
import 'package:service_finder_application/database/firestore.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  final FirestoreDatabase database = FirestoreDatabase();

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String _searchQuery = "";

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _searchQuery = "";
    });
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
          preferredSize: const Size.fromHeight(50.0),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
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
          ),
        ),
      ),
      drawer: const MyDrawer(),
      body: Column(
        children: [
          Expanded(
            child: _selectedIndex == 0
                ? ProvidersPostList(
                    database: widget.database, searchQuery: _searchQuery)
                : AskForServicePostList(
                    database: widget.database, searchQuery: _searchQuery),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
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
    );
  }
}
