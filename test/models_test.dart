import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:service_finder_application/features/auth/models/registration_data.dart';
import 'package:service_finder_application/features/chat/models/message.dart';
import 'package:service_finder_application/features/home/models/post_filter.dart';
import 'package:service_finder_application/features/posts/models/service_post.dart';
import 'package:service_finder_application/features/profile/models/user_profile.dart';

void main() {
  test('Both registration roles keep the existing Users document schema', () {
    for (final provider in [false, true]) {
      final profile = RegistrationData(
        username: 'Sam',
        email: 'sam@example.com',
        isProvider: provider,
      ).toProfile(userId: 'firebase-uid');
      expect(profile.toMap(), {
        'user_ID': 'firebase-uid',
        'email': 'sam@example.com',
        'username': 'Sam',
        'provider': provider,
      });
    }
  });

  test('Profile round-trip retains optional fields and the stored identity',
      () {
    final data = <String, dynamic>{
      'user_ID': 'firebase-uid',
      'email': 'sam@example.com',
      'username': 'Sam',
      'provider': true,
      'profileImage': 'https://example.com/avatar.jpg',
      'bio': 'Electrician',
      'phone': '0771234567',
      'address': 'Colombo',
      'userType': 'Provider',
    };
    expect(UserProfile.fromMap(data).toMap(), data);
    final missing = UserProfile.fromMap({});
    expect(missing.isProvider, isFalse);
    expect(missing.profileImage, isNull);
    expect(missing.username, isNull);
  });

  test('Canonical provider flag takes precedence, with a legacy role fallback',
      () {
    expect(UserProfile.fromMap({'provider': true}).isProvider, isTrue);
    expect(UserProfile.fromMap({'userType': 'Provider'}).isProvider, isTrue);
    expect(
        UserProfile.fromMap({
          'provider': false,
          'userType': 'Provider',
        }).isProvider,
        isFalse);
  });

  test('Post serialization preserves existing Firestore names and values', () {
    final data = <String, dynamic>{
      'post_ID': 'post-document',
      'UserID': 'firebase-uid',
      'UserEmail': 'sam@example.com',
      'username': 'Sam',
      'PostMessage': 'House wiring',
      'ask': false,
      'Description': 'Electrical repairs',
      'Mobile1': '0771234567',
      'Mobile2': null,
      'Address': 'Colombo',
      'WhatsappLink': 'https://example.com/whatsapp',
      'FacebookLink': 'https://example.com/facebook',
      'WebsiteLink': 'https://example.com',
      'Location': 'Colombo',
      'ImageUrls': ['https://example.com/post.jpg'],
      'TimeStamp': Timestamp(1700000000, 123),
    };
    expect(ServicePost.fromMap(data).toMap(), data);
  });

  test('Legacy post defaults preserve document identity and unknown feed type',
      () {
    final post = ServicePost.fromMap({}, documentId: 'fallback-id');
    expect(post.id, 'fallback-id');
    expect(post.imageUrls, isEmpty);
    expect(post.isAsk, isNull);
    expect(post.timestamp, isNull);
    expect(
        ServicePost.fromMap({
          'post_ID': 'stored-id',
          'ask': true,
          'ImageUrls': null,
        }, documentId: 'fallback-id')
            .id,
        'stored-id');
  });

  test('Post image lists are copied and immutable', () {
    final images = ['first.jpg'];
    final post = ServicePost(
      id: 'post',
      userId: 'user',
      message: 'Repair',
      isAsk: true,
      imageUrls: images,
    );
    images.add('second.jpg');
    expect(post.imageUrls, ['first.jpg']);
    expect(() => post.imageUrls.add('third.jpg'), throwsUnsupportedError);
  });

  test(
      'Home filters combine case-insensitive title/name search and exact location',
      () {
    final post = ServicePost(
      id: 'post',
      userId: 'user',
      message: 'House wiring',
      isAsk: false,
      username: 'Sam',
      location: 'Colombo',
    );
    expect(const PostFilter().matches(post), isTrue);
    expect(const PostFilter(searchQuery: 'WIRING').matches(post), isTrue);
    expect(
        const PostFilter(searchQuery: 'sAm', location: 'Colombo').matches(post),
        isTrue);
    expect(
        const PostFilter(searchQuery: 'sAm', location: 'Kandy').matches(post),
        isFalse);
    expect(const PostFilter(searchQuery: 'plumbing').matches(post), isFalse);
    expect(const PostFilter(location: 'Kandy').matches(post), isFalse);
    expect(const PostFilter(location: null).matches(post), isTrue);
  });

  test('Message decoding preserves stored timestamp and participant IDs', () {
    final data = <String, dynamic>{
      'senderId': 'sender',
      'senderEmail': 'sender@example.com',
      'receiverId': 'receiver',
      'message': 'Hello',
      'timestamp': Timestamp(1700000000, 123),
    };
    final message = Message.fromMap(data);
    expect(message.toMap(), data);
    expect(message.timestamp, data['timestamp']);
  });
}
