import 'package:flutter/material.dart';
import 'package:service_finder_application/shared/widgets/my_textfield.dart';

class MessageInput extends StatelessWidget {
  const MessageInput(
      {super.key, required this.controller, required this.onSend});
  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: MyTextField(
                hintText: "Type a message...",
                obscureText: false,
                controller: controller,
                keyboardType: TextInputType.text,
              ),
            ),
          ),
          IconButton(
            onPressed: onSend,
            icon: Icon(
              Icons.send,
              size: 40,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
