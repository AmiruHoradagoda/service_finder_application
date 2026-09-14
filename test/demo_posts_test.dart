import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:service_finder_application/features/posts/services/demo_posts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('JSON demo listings resolve details and bundle all six images', () async {
    final posts = await DemoPosts.load();
    expect(posts.where((post) => post.isAsk == false), hasLength(6));
    expect(posts.where((post) => post.isAsk == true), hasLength(3));
    final avatars = posts.map((post) => post.avatarUrl!).toSet();
    final images = posts.expand((post) => post.imageUrls).toSet();
    expect(avatars, hasLength(3));
    expect(images, hasLength(3));
    for (final path in {...avatars, ...images}) {
      expect((await rootBundle.load(path)).lengthInBytes, greaterThan(100));
    }
    expect(await DemoPosts.find(posts.first.id), same(posts.first));
    expect(await DemoPosts.find('real-post-id'), isNull);
  });
}
