import 'package:flutter/material.dart';
import 'package:service_finder_application/features/posts/models/service_post.dart';

class ProfilePostsList extends StatelessWidget {
  const ProfilePostsList(
      {super.key, required this.posts, required this.onDelete});
  final Future<List<ServicePost>> posts;
  final ValueChanged<String> onDelete;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ServicePost>>(
      // Fetch user posts
      future: posts,
      builder: (context, postsSnapshot) {
        if (postsSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (postsSnapshot.hasError) {
          return Text("Error: ${postsSnapshot.error}");
        } else if (postsSnapshot.hasData) {
          final posts = postsSnapshot.data!;
          return Expanded(
            child: ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                final postId = post.id;
                final message = post.message;
                final username = post.username;
                final thumbnailUrl =
                    post.imageUrls.isEmpty ? null : post.imageUrls.first;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(message,
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                      subtitle: Text(username ?? 'Unknown user'),
                      leading: thumbnailUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                thumbnailUrl,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(Icons.image, size: 50),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => onDelete(postId),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        } else {
          return const Center(child: Text("No posts found"));
        }
      },
    );
  }
}
