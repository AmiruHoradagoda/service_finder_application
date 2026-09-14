import 'package:service_finder_application/features/home/widgets/home_search_bar.dart';
import 'package:service_finder_application/features/home/widgets/home_bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:service_finder_application/features/home/models/post_filter.dart';
import 'package:service_finder_application/features/home/widgets/ask_for_service_post_list.dart';
import 'package:service_finder_application/features/home/widgets/my_drawer.dart';
import 'package:service_finder_application/features/home/widgets/providers_post_list.dart';
import 'package:service_finder_application/features/home/services/home_service.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  final HomeService service = HomeService();

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

  @override
  Widget build(BuildContext context) {
    final filter =
        PostFilter(searchQuery: _searchQuery, location: _selectedLocation);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 2,
        bottom: HomeSearchBar(
          onSearchChanged: (value) => setState(() => _searchQuery = value),
          onLocationChanged: _onLocationChanged,
        ),
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
                      service: widget.service,
                      filter: filter,
                    )
                  : AskForServicePostList(
                      key: const ValueKey(1),
                      service: widget.service,
                      filter: filter,
                    ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: HomeBottomNavigation(
          selectedIndex: _selectedIndex, onTap: _onItemTapped),
    );
  }
}
