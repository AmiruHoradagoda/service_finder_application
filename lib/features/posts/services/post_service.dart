import 'dart:io';
import 'dart:typed_data';
import 'package:service_finder_application/features/posts/services/demo_posts.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:service_finder_application/features/posts/models/service_post.dart';
import 'package:service_finder_application/features/profile/services/profile_service.dart';

class PostService {
  PostService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
    ProfileService? profiles,
  })  : _auth = auth,
        _firestore = firestore,
        _storage = storage,
        _profiles = profiles;

  final FirebaseAuth? _auth;
  final FirebaseFirestore? _firestore;
  final FirebaseStorage? _storage;
  final ProfileService? _profiles;
  FirebaseAuth get _firebaseAuth => _auth ?? FirebaseAuth.instance;
  FirebaseFirestore get _database => _firestore ?? FirebaseFirestore.instance;
  FirebaseStorage get _imageStorage => _storage ?? FirebaseStorage.instance;
  ProfileService get _profileService =>
      _profiles ?? ProfileService(auth: _firebaseAuth, firestore: _database);

  Future<void> addPost({
    required String message,
    required bool isAsk,
    required String description,
    required String mobile1,
    String? mobile2,
    required String address,
    String? whatsappLink,
    String? facebookLink,
    String? websiteLink,
    List<File?> imageFiles = const [],
    List<Uint8List?> imageBytes = const [],
    required String location,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null || user.email == null) {
      throw StateError('Please sign in to create a post.');
    }
    final profile = await _profileService.getProfile(user.email!);
    final imageUrls = <String>[];
    for (final image in imageFiles) {
      if (image == null) continue;
      final fileName = DateTime.now().microsecondsSinceEpoch.toString();
      final reference = _imageStorage.ref().child('post_images/$fileName');
      await reference.putFile(image);
      imageUrls.add(await reference.getDownloadURL());
    }
    for (final bytes in imageBytes) {
      if (bytes == null) continue;
      final reference = _imageStorage
          .ref()
          .child('post_images/${DateTime.now().microsecondsSinceEpoch}');
      await reference.putData(bytes);
      imageUrls.add(await reference.getDownloadURL());
    }
    final document = _database.collection('Posts').doc();
    final post = ServicePost(
      id: document.id,
      userId: user.uid,
      userEmail: user.email,
      username: profile?.username,
      message: message,
      isAsk: isAsk,
      description: description,
      mobile1: mobile1,
      mobile2: mobile2,
      address: address,
      whatsappLink: whatsappLink,
      facebookLink: facebookLink,
      websiteLink: websiteLink,
      location: location,
      imageUrls: imageUrls,
      timestamp: Timestamp.now(),
    );
    // Errors propagate to the form, so a failed write cannot appear successful.
    await document.set(post.toMap());
  }

  Future<ServicePost?> getPostById(String postId) async {
    final demo = await DemoPosts.find(postId);
    if (demo != null) return demo;
    final document = await _database.collection('Posts').doc(postId).get();
    final data = document.data();
    return data == null
        ? null
        : ServicePost.fromMap(data, documentId: document.id);
  }

  Stream<List<ServicePost>> getPostsStream() => _database
      .collection('Posts')
      .orderBy('TimeStamp', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => ServicePost.fromMap(doc.data(), documentId: doc.id))
          .toList());

  Future<List<ServicePost>> getCurrentUserPosts() async {
    final email = _firebaseAuth.currentUser?.email;
    if (email == null) return [];
    final snapshot = await _database
        .collection('Posts')
        .where('UserEmail', isEqualTo: email)
        .get();
    return snapshot.docs
        .map((doc) => ServicePost.fromMap(doc.data(), documentId: doc.id))
        .toList();
  }

  Future<void> deletePost(String postId) =>
      _database.collection('Posts').doc(postId).delete();
}
