import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderId;
  final String senderEmail;
  final String receiverId;
  final String message;
  final Timestamp timestamp;

  const Message({
    required this.senderId,
    required this.senderEmail,
    required this.receiverId,
    required this.message,
    required this.timestamp,
  });

  factory Message.fromMap(Map<String, dynamic> data) => Message(
        senderId: data['senderId'] as String,
        senderEmail: data['senderEmail'] as String,
        receiverId: data['receiverId'] as String,
        message: data['message'] as String,
        timestamp: data['timestamp'] as Timestamp,
      );

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderEmail': senderEmail,
      'receiverId': receiverId,
      'message': message,
      'timestamp': timestamp,
    };
  }
}
