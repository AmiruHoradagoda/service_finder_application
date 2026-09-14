import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:service_finder_application/features/auth/models/registration_data.dart';
import 'package:service_finder_application/features/auth/services/auth_service.dart';
import 'package:service_finder_application/features/chat/services/chat_service.dart';
import 'package:service_finder_application/features/home/models/post_filter.dart';
import 'package:service_finder_application/features/home/services/home_service.dart';
import 'package:service_finder_application/features/posts/models/service_post.dart';
import 'package:service_finder_application/features/posts/services/post_service.dart';
import 'package:service_finder_application/features/profile/models/user_profile.dart';
import 'package:service_finder_application/features/profile/services/profile_service.dart';

class TestUser extends Fake implements User {
  TestUser(this.uid, this.email);
  @override
  final String uid;
  @override
  final String email;
  String? updatedPassword;
  @override
  Future<void> updatePassword(String newPassword) async {
    updatedPassword = newPassword;
  }
}

class TestCredential extends Fake implements UserCredential {
  TestCredential(this.user);
  @override
  final User user;
}

class TestAuth extends Fake implements FirebaseAuth {
  TestAuth(this.currentUser);
  @override
  User? currentUser;
  final events = StreamController<User?>.broadcast(sync: true);
  String? signedInEmail;

  @override
  Stream<User?> authStateChanges() => events.stream;

  @override
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    currentUser = TestUser('new-uid', email);
    events.add(currentUser);
    return TestCredential(currentUser!);
  }

  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    signedInEmail = email;
    currentUser = TestUser('signed-in-uid', email);
    events.add(currentUser);
    return TestCredential(currentUser!);
  }

  @override
  Future<void> signOut() async {
    currentUser = null;
    events.add(null);
  }
}

class RecordingProfiles extends ProfileService {
  UserProfile? created;
  Completer<void>? pendingWrite;
  Object? failure;
  final profile = const UserProfile(
    userId: 'owner',
    username: 'Sam',
    email: 'sam@example.com',
    isProvider: true,
  );

  @override
  Future<void> createProfile(UserProfile profile) async {
    created = profile;
    if (pendingWrite != null) await pendingWrite!.future;
    if (failure != null) throw failure!;
  }

  @override
  Future<UserProfile?> getProfile(String email) async => profile;

  @override
  Stream<List<UserProfile>> getProfilesStream() => Stream.value([profile]);
}

class RecordingDatabase extends Fake implements FirebaseFirestore {
  final writes = <String, Map<String, dynamic>>{};
  final updates = <String, Map<Object, Object?>>{};
  Object? writeFailure;

  @override
  CollectionReference<Map<String, dynamic>> collection(String path) =>
      RecordingCollection(this, path);
}

// Test-only stand-in for the SDK interface; production uses Firebase's implementation.
// ignore: subtype_of_sealed_class
class RecordingCollection extends Fake
    implements CollectionReference<Map<String, dynamic>> {
  RecordingCollection(this.database, this.path);
  final RecordingDatabase database;
  @override
  final String path;

  @override
  DocumentReference<Map<String, dynamic>> doc([String? path]) =>
      RecordingDocument(database, '${this.path}/${path ?? 'generated-id'}');
}

// Test-only stand-in for the SDK interface; production uses Firebase's implementation.
// ignore: subtype_of_sealed_class
class RecordingDocument extends Fake
    implements DocumentReference<Map<String, dynamic>> {
  RecordingDocument(this.database, this.path);
  final RecordingDatabase database;
  @override
  final String path;
  @override
  String get id => path.split('/').last;

  @override
  Future<void> set(Map<String, dynamic> data, [SetOptions? options]) async {
    if (database.writeFailure != null) throw database.writeFailure!;
    database.writes[path] = Map.of(data);
  }

  @override
  Future<void> update(Map<Object, Object?> data) async {
    database.updates[path] = Map.of(data);
  }
}

class FeedPosts extends PostService {
  FeedPosts(this.posts);
  final List<ServicePost> posts;
  @override
  Stream<List<ServicePost>> getPostsStream() => Stream.value(posts);
}

void main() {
  late TestAuth auth;
  late RecordingProfiles profiles;
  late RecordingDatabase database;
  setUp(() {
    auth = TestAuth(TestUser('owner', 'sam@example.com'));
    profiles = RecordingProfiles();
    database = RecordingDatabase();
  });
  tearDown(() => auth.events.close());

  test('Registration awaits the profile write and preserves the selected role',
      () async {
    profiles.pendingWrite = Completer<void>();
    final service = AuthService(auth: auth, profiles: profiles);
    var completed = false;
    final request = service
        .register(
          registration: const RegistrationData(
            username: 'Sam',
            email: 'sam@example.com',
            isProvider: true,
          ),
          password: 'test-password',
        )
        .then((_) => completed = true);
    await Future<void>.delayed(Duration.zero);
    expect(profiles.created?.userId, 'new-uid');
    expect(profiles.created?.isProvider, isTrue);
    expect(completed, isFalse);
    profiles.pendingWrite!.complete();
    await request;
    expect(completed, isTrue);
  });

  test('Registration exposes a failed profile write to the authentication UI',
      () async {
    profiles.failure = StateError('write failed');
    final service = AuthService(auth: auth, profiles: profiles);
    await expectLater(
        service.register(
          registration: const RegistrationData(
            username: 'Sam',
            email: 'sam@example.com',
            isProvider: false,
          ),
          password: 'test-password',
        ),
        throwsStateError);
  });

  test('Sign-in and logout expose session changes to navigation', () async {
    final service = AuthService(auth: auth);
    final sessions = <String?>[];
    final subscription = service.sessionChanges.listen(sessions.add);
    await service.signIn(email: 'sam@example.com', password: 'test-password');
    await service.signOut();
    expect(auth.signedInEmail, 'sam@example.com');
    expect(sessions, ['signed-in-uid', null]);
    await subscription.cancel();
  });

  test('Post creation uses the current account and the generated document ID',
      () async {
    final service =
        PostService(auth: auth, firestore: database, profiles: profiles);
    Future<void> create() => service.addPost(
          message: 'Repair',
          isAsk: true,
          description: 'Help needed',
          mobile1: '0771234567',
          address: 'Colombo',
          location: 'Colombo',
        );
    await create();
    var data = database.writes['Posts/generated-id']!;
    expect(data['post_ID'], 'generated-id');
    expect(data['UserID'], 'owner');
    expect(data['UserEmail'], 'sam@example.com');
    expect(data['username'], 'Sam');
    expect(data['ImageUrls'], isEmpty);
    expect(data['TimeStamp'], isA<Timestamp>());

    auth.currentUser = TestUser('another-user', 'another@example.com');
    await create();
    data = database.writes['Posts/generated-id']!;
    expect(data['UserID'], 'another-user');
    expect(data['UserEmail'], 'another@example.com');
  });

  test('A failed post write is propagated instead of reporting success',
      () async {
    database.writeFailure = StateError('write failed');
    final service =
        PostService(auth: auth, firestore: database, profiles: profiles);
    await expectLater(
        service.addPost(
          message: 'Repair',
          isAsk: true,
          description: 'Help needed',
          mobile1: '0771234567',
          address: 'Colombo',
          location: 'Colombo',
        ),
        throwsStateError);
    expect(database.writes, isEmpty);
  });

  test('Profile edits update only editable fields at the existing document key',
      () async {
    final service = ProfileService(auth: auth, firestore: database);
    await service.updateProfile(
      username: 'New name',
      email: 'new@example.com',
      password: 'new-password',
    );
    expect(database.updates['Users/sam@example.com'], {
      'username': 'New name',
      'email': 'new@example.com',
    });
    expect((auth.currentUser! as TestUser).updatedPassword, 'new-password');
    expect(database.writes, isEmpty);
  });

  test('Home combines feed type and filters without changing post order',
      () async {
    final posts = [
      ServicePost(id: 'provider', userId: 'u', message: 'Repair', isAsk: false),
      ServicePost(
          id: 'first',
          userId: 'u',
          message: 'Repair',
          isAsk: true,
          location: 'Colombo'),
      ServicePost(id: 'legacy', userId: 'u', message: 'Repair', isAsk: null),
      ServicePost(
          id: 'second',
          userId: 'u',
          message: 'Repair',
          isAsk: true,
          location: 'Colombo'),
    ];
    final service = HomeService(posts: FeedPosts(posts));
    final result = service.filterPosts(await service.getPostsStream().first,
        isAsk: true,
        filter: const PostFilter(searchQuery: 'REPAIR', location: 'Colombo'));
    expect(result.map((post) => post.id), ['first', 'second']);
  });

  test('Chat exposes typed contacts through the shared profile service',
      () async {
    final service = ChatService(profiles: profiles);
    final contacts = await service.getUsersStream().first;
    expect(contacts.single, same(profiles.profile));
    service.dispose();
  });

  test('Services reject writes without an authenticated account', () async {
    auth.currentUser = null;
    final posts =
        PostService(auth: auth, firestore: database, profiles: profiles);
    await expectLater(
        posts.addPost(
          message: 'Repair',
          isAsk: true,
          description: '',
          mobile1: '123',
          address: '',
          location: 'Colombo',
        ),
        throwsStateError);
    final profileService = ProfileService(auth: auth, firestore: database);
    await expectLater(
        profileService.updateProfile(username: 'Sam', email: 'sam@example.com'),
        throwsStateError);
    final chat = ChatService(auth: auth);
    await expectLater(chat.sendMessage('receiver', 'Hello'), throwsStateError);
    expect(database.writes, isEmpty);
    chat.dispose();
  });
}
