import 'package:flutter/material.dart';
import 'package:service_finder_application/components/my_list_tile.dart';
import 'package:service_finder_application/database/firestore.dart';
import 'package:service_finder_application/pages/open_post_page.dart';

class ProvidersPostList extends StatelessWidget {
  final FirestoreDatabase database;
  final String searchQuery; // Added searchQuery parameter
  final String? selectedLocation; // Added location parameter

  const ProvidersPostList({
    super.key,
    required this.database,
    required this.searchQuery, // Initialize searchQuery
    this.selectedLocation, // Initialize location parameter
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: database.getPostsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(25),
              child: Text("No provider posts..."),
            ),
          );
        }

        // Filtering posts where 'ask' == false
        final posts = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>?; // Cast to Map
          if (data == null ||
              !data.containsKey('ask') ||
              data['ask'] != false) {
            return false;
          }

          // Apply location filter
          if (selectedLocation != null &&
              data['Location'] != selectedLocation) {
            return false;
          }

          // Apply search filter
          if (searchQuery.isNotEmpty) {
            String message =
                data['PostMessage']?.toString().toLowerCase() ?? '';
            String username = data['username']?.toString().toLowerCase() ?? '';
            return message.contains(searchQuery.toLowerCase()) ||
                username.contains(searchQuery.toLowerCase());
          }
          return true; // Include post if searchQuery is empty
        }).toList(); // Convert the filtered result to a List

        if (posts.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(25),
              child: Text("No provider posts matching your search..."),
            ),
          );
        }

        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            final data = post.data() as Map<String, dynamic>; // Cast to Map

            String message = data['PostMessage'];
            String? username =
                data['username']; // Get username instead of email
            List<dynamic> imageUrls =
                data['ImageUrls'] ?? []; // Retrieve the image URLs
            String? thumbnailUrl = imageUrls.isNotEmpty ? imageUrls[0] : null;
            String postId = data['post_ID']; // Fetch post_ID from the post data

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OpenedPostPage(
                      postId: postId, // Pass post_ID to OpenedPostPage
                    ),
                  ),
                );
              },
              child: MyListTile(
                title: message,
                subtitle: username ?? 'Unknown user', // Display username
                leadingImage:
                    thumbnailUrl, // Display the first image as thumbnail
              ),
            );
          },
        );
      },
    );
  }
}
