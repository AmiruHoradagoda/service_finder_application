import 'package:service_finder_application/features/home/widgets/home_search_bar.dart';
import 'package:service_finder_application/features/home/widgets/home_bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
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
  bool _showDemo = kDebugMode;
  final HomeService _demoService = HomeService(demo: true);
  int _selectedIndex = 0;
  String _searchQuery = "";
  String? _selectedLocation; // Store the selected location

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
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
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.brightness == Brightness.dark
          ? const Color(0xFF10292C)
          : const Color(0xFFF3F8F8),
      appBar: AppBar(
        title: const Text('Service Finder',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        actions: [
          const Text('Demo data'),
          Switch(
            value: _showDemo,
            onChanged: (value) => setState(() => _showDemo = value),
          ),
        ],
        backgroundColor: const Color(0xFF087F88),
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: HomeSearchBar(
          onSearchChanged: (value) => setState(() => _searchQuery = value),
          onLocationChanged: _onLocationChanged,
        ),
      ),
      drawer: const MyDrawer(),
      body: Center(
          child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 12),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        _selectedIndex == 0
                            ? 'A little help, close to home.'
                            : 'Your skills. Someone?s solution.',
                        style: const TextStyle(
                            fontSize: 25,
                            height: 1.15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.8)),
                    const SizedBox(height: 8),
                    Text(
                        _selectedIndex == 0
                            ? 'Find the right people for your everyday projects.'
                            : 'Explore what your community needs help with.',
                        style: TextStyle(
                            fontSize: 13,
                            color: theme.colorScheme.onSurfaceVariant)),
                    if (_selectedLocation != null)
                      Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: InputChip(
                              label: Text(_selectedLocation!),
                              avatar: const Icon(Icons.location_on_outlined,
                                  size: 16),
                              onDeleted: () => _onLocationChanged(null))),
                  ]),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _selectedIndex == 0
                    ? ProvidersPostList(
                        key: ValueKey('providers-$_showDemo'),
                        service: _showDemo ? _demoService : widget.service,
                        filter: filter,
                      )
                    : AskForServicePostList(
                        key: ValueKey('requests-$_showDemo'),
                        service: _showDemo ? _demoService : widget.service,
                        filter: filter,
                      ),
              ),
            ),
          ],
        ),
      )),
      bottomNavigationBar: HomeBottomNavigation(
          selectedIndex: _selectedIndex, onTap: _onItemTapped),
    );
  }
}
