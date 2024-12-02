import 'package:flutter/material.dart';
import 'package:service_finder_application/components/my_list_tile.dart';
import 'package:service_finder_application/database/firestore.dart';
import 'package:service_finder_application/pages/open_post_page.dart';

class AskForServicePostList extends StatelessWidget {
  final FirestoreDatabase database;
  final String searchQuery;
  final String? selectedLocation; // Added location parameter

  const AskForServicePostList({
    super.key,
    required this.database,
    required this.searchQuery,
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
              child: Text("No service requests..."),
            ),
          );
        }

        // Filtering posts where 'ask' == true
        final posts = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>?;

          if (data == null || !data.containsKey('ask') || data['ask'] != true) {
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
          return true;
        }).toList();

        if (posts.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(25),
              child: Text("No service requests matching your search..."),
            ),
          );
        }

        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            final data = post.data() as Map<String, dynamic>;

            String message = data['PostMessage'];
            String? username = data['username'];
            List<dynamic> imageUrls = data['ImageUrls'] ?? [];
            String? thumbnailUrl = imageUrls.isNotEmpty ? imageUrls[0] : null;
            String postId = data['post_ID'];

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OpenedPostPage(postId: postId),
                  ),
                );
              },
              child: MyListTile(
                title: message,
                subtitle: username ?? 'Unknown user',
                leadingImage: thumbnailUrl,
              ),
            );
          },
        );
      },
    );
  }
}
