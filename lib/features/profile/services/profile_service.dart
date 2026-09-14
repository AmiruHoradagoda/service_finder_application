import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:service_finder_application/features/profile/models/user_profile.dart';

class ProfileService {
  ProfileService(
      {FirebaseAuth? auth,
      FirebaseFirestore? firestore,
      FirebaseStorage? storage})
      : _auth = auth,
        _firestore = firestore,
        _storage = storage;

  final FirebaseAuth? _auth;
  final FirebaseFirestore? _firestore;
  final FirebaseStorage? _storage;
  FirebaseAuth get _firebaseAuth => _auth ?? FirebaseAuth.instance;
  FirebaseFirestore get _database => _firestore ?? FirebaseFirestore.instance;
  FirebaseStorage get _imageStorage => _storage ?? FirebaseStorage.instance;

  Future<UserProfile?> getCurrentProfile() async {
    final email = _firebaseAuth.currentUser?.email;
    return email == null ? null : getProfile(email);
  }

  Future<UserProfile?> getProfile(String email) async {
    final document = await _database.collection('Users').doc(email).get();
    final data = document.data();
    return data == null ? null : UserProfile.fromMap(data);
  }

  Future<void> createProfile(UserProfile profile) async {
    final email = profile.email;
    if (email == null || email.isEmpty) {
      throw ArgumentError('A profile must have an email address.');
    }
    await _database.collection('Users').doc(email).set(profile.toMap());
  }

  Stream<List<UserProfile>> getProfilesStream() =>
      _database.collection('Users').snapshots().map((snapshot) =>
          snapshot.docs.map((doc) => UserProfile.fromMap(doc.data())).toList());

  Future<void> updateProfile({
    required String username,
    required String email,
    String password = '',
    File? image,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null || user.email == null) {
      throw StateError('Please sign in to update your profile.');
    }
    String? imageUrl;
    if (image != null) {
      final reference = _imageStorage.ref().child('profile_images/${user.uid}');
      await reference.putFile(image);
      imageUrl = await reference.getDownloadURL();
    }
    // Keep the existing document key and metadata-only email update behavior.
    await _database.collection('Users').doc(user.email).update({
      'username': username,
      'email': email,
      if (imageUrl != null) 'profileImage': imageUrl,
    });
    if (password.isNotEmpty) await user.updatePassword(password);
  }
}
