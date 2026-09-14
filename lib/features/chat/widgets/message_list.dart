import 'package:flutter/material.dart';
import 'package:service_finder_application/features/chat/models/message.dart';
import 'package:service_finder_application/features/chat/widgets/message_bubble.dart';

class MessageList extends StatelessWidget {
  const MessageList(
      {super.key, required this.messages, required this.currentUserId});
  final Stream<List<Message>> messages;
  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: messages,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No messages yet."));
        }
        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            return MessageBubble(
                message: snapshot.data![index],
                isSentByMe: snapshot.data![index].senderId == currentUserId);
          },
        );
      },
    );
  }
}
