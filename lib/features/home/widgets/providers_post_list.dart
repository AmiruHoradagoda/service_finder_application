import 'package:flutter/material.dart';
import 'package:service_finder_application/features/home/models/post_filter.dart';
import 'package:service_finder_application/features/home/widgets/service_listing_card.dart';
import 'package:service_finder_application/features/home/services/home_service.dart';
import 'package:service_finder_application/routes/app_routes.dart';

class ProvidersPostList extends StatelessWidget {
  final HomeService service;
  final PostFilter filter;

  const ProvidersPostList({
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
              child: Text("No provider posts..."),
            ),
          );
        }

        final posts = service.filterPosts(
          snapshot.data!,
          isAsk: false,
          filter: filter,
        );

        if (posts.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(25),
              child: Text("No provider posts matching your search..."),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          itemCount: posts.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) => ServiceListingCard(
            post: posts[index],
            onTap: () => AppRoutes.openPost(context, postId: posts[index].id),
          ),
        );
      },
    );
  }
}
