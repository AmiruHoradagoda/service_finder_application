import 'package:flutter/material.dart';
import 'package:service_finder_application/features/chat/models/message.dart';
import 'package:intl/intl.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble(
      {super.key, required this.message, required this.isSentByMe});
  final Message message;
  final bool isSentByMe;

  @override
  Widget build(BuildContext context) {
    final alignment = isSentByMe ? Alignment.centerRight : Alignment.centerLeft;
    final backgroundColor = isSentByMe ? Colors.teal[100] : Colors.grey[300];
    final textColor = isSentByMe ? Colors.black : Colors.black87;
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Column(
        crossAxisAlignment:
            isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(12),
            child: Text(
              message.message,
              style: TextStyle(color: textColor),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            DateFormat('hh:mm a').format(message.timestamp.toDate()),
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
