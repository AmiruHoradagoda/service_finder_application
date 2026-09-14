import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:service_finder_application/features/profile/services/profile_service.dart';
import 'package:service_finder_application/features/profile/models/user_profile.dart';
import 'package:service_finder_application/features/chat/models/message.dart';

class ChatService extends ChangeNotifier {
  ChatService(
      {FirebaseAuth? auth,
      FirebaseFirestore? firestore,
      ProfileService? profiles})
      : _auth = auth,
        _database = firestore,
        _profiles = profiles;

  final FirebaseAuth? _auth;
  final FirebaseFirestore? _database;
  final ProfileService? _profiles;
  FirebaseAuth get _firebaseAuth => _auth ?? FirebaseAuth.instance;
  FirebaseFirestore get _firestore => _database ?? FirebaseFirestore.instance;

  String get currentUserId => _firebaseAuth.currentUser?.uid ?? '';

  Stream<List<UserProfile>> getUsersStream() =>
      (_profiles ?? ProfileService(auth: _firebaseAuth, firestore: _firestore))
          .getProfilesStream();

  Future<void> sendMessage(String receiverId, String message) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw StateError('Please sign in to send a message.');
    final String currentUserId = user.uid;
    final String currentUserEmail = user.email.toString();
    final Timestamp timestamp = Timestamp.now();

    Message newMessage = Message(
      senderId: currentUserId,
      senderEmail: currentUserEmail,
      receiverId: receiverId,
      message: message,
      timestamp: timestamp,
    );

    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatRoomId = ids.join("_");

    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(newMessage.toMap());
  }

  Stream<List<Message>> getMessages(String userId, String otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join("_");

    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Message.fromMap(doc.data())).toList());
  }
}
