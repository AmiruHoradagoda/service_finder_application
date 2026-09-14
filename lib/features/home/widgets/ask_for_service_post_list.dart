import 'package:flutter/material.dart';
import 'package:service_finder_application/features/home/models/post_filter.dart';
import 'package:service_finder_application/shared/widgets/my_list_tile.dart';
import 'package:service_finder_application/features/home/services/home_service.dart';
import 'package:service_finder_application/routes/app_routes.dart';

class AskForServicePostList extends StatelessWidget {
  final HomeService service;
  final PostFilter filter;

  const AskForServicePostList({
    super.key,
    required this.service,
    required this.filter,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: service.getPostsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.data == null || snapshot.data!.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(25),
              child: Text("No service requests..."),
            ),
          );
        }

        final posts = service.filterPosts(
          snapshot.data!,
          isAsk: true,
          filter: filter,
        );

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
            final message = post.message;
            final username = post.username;
            final thumbnailUrl =
                post.imageUrls.isEmpty ? null : post.imageUrls.first;
            final postId = post.id;

            return GestureDetector(
              onTap: () {
                AppRoutes.openPost(context, postId: postId);
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
