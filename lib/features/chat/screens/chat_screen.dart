import 'package:service_finder_application/features/chat/widgets/message_list.dart';
import 'package:service_finder_application/features/chat/widgets/message_input.dart';
import 'package:flutter/material.dart';
import 'package:service_finder_application/features/chat/services/chat_service.dart';

class ChatPage extends StatefulWidget {
  final String receiverUserEmail;
  final String receiverUserID;

  const ChatPage({
    super.key,
    required this.receiverUserEmail,
    required this.receiverUserID,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(
        widget.receiverUserID,
        _messageController.text.trim(),
      );
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverUserEmail),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: MessageList(
                  messages: _chatService.getMessages(
                      widget.receiverUserID, _chatService.currentUserId),
                  currentUserId: _chatService.currentUserId),
            ),
            MessageInput(controller: _messageController, onSend: sendMessage),
          ],
        ),
      ),
    );
  }
}
