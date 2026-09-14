import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:service_finder_application/features/posts/models/service_post.dart';

/// Local JSON samples, never persisted to Firebase.
class DemoPosts {
  static Future<List<ServicePost>>? _posts;
  static Future<List<ServicePost>> load() => _posts ??= _load();

  static Future<List<ServicePost>> _load() async {
    final json =
        jsonDecode(await rootBundle.loadString('assets/demo/posts.json'))
            as List;
    return List.unmodifiable(json.map(
        (row) => ServicePost.fromMap(Map<String, dynamic>.from(row as Map))));
  }

  static Future<ServicePost?> find(String id) async {
    if (!id.startsWith('demo-')) return null;
    for (final post in await load()) {
      if (post.id == id) return post;
    }
    return null;
  }
}
