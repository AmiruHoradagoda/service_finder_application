import 'package:service_finder_application/features/posts/models/service_post.dart';

/// Home's search and location selection, shared by both feeds.
class PostFilter {
  const PostFilter({this.searchQuery = '', this.location});

  final String searchQuery;
  final String? location;

  bool matches(ServicePost post) {
    if (location != null && post.location != location) return false;
    final query = searchQuery.toLowerCase();
    return query.isEmpty ||
        post.message.toLowerCase().contains(query) ||
        (post.username?.toLowerCase().contains(query) ?? false);
  }
}
