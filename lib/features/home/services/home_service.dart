import 'package:service_finder_application/features/home/models/post_filter.dart';
import 'package:service_finder_application/features/posts/models/service_post.dart';
import 'package:service_finder_application/features/posts/services/post_service.dart';
import 'package:service_finder_application/features/posts/services/demo_posts.dart';

/// Home composes post retrieval and feed selection; Posts owns persistence.
class HomeService {
  HomeService({PostService? posts, this.demo = false})
      : _posts = posts ?? PostService();

  final bool demo;

  final PostService _posts;

  Stream<List<ServicePost>> getPostsStream() =>
      demo ? Stream.fromFuture(DemoPosts.load()) : _posts.getPostsStream();

  List<ServicePost> filterPosts(
    List<ServicePost> posts, {
    required bool isAsk,
    required PostFilter filter,
  }) =>
      posts
          .where((post) => post.isAsk == isAsk && filter.matches(post))
          .toList();
}
