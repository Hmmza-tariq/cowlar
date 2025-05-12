import 'package:flutter/material.dart';

class MessageList extends StatelessWidget {
  final List<String> messages;

  const MessageList({super.key, required this.messages});

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return const Center(
        child: Text(
          'No messages received yet',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[messages.length - 1 - index];

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.message),
            ),
            title: Text(
              message,
              style: const TextStyle(fontSize: 14),
            ),
            subtitle: Text(
              'Message #${messages.length - index}',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        );
      },
    );
  }
}
