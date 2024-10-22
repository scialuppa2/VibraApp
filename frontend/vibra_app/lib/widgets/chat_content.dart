import 'package:flutter/material.dart';
import 'package:vibra_app/models/chat.dart';
import 'package:vibra_app/widgets/message_bubble.dart';
import 'package:intl/intl.dart';


import '../models/message.dart';

class ChatContent extends StatelessWidget {
  final Chat chat;
  final String? currentUserId;
  final ScrollController scrollController;
  final String searchQuery;

  const ChatContent({
    Key? key,
    required this.chat,
    required this.currentUserId,
    required this.scrollController,
    required this.searchQuery,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final filteredMessages = chat.messages.where((message) {
      return message.content.contains(searchQuery) ||
          (message.originalFileName?.contains(searchQuery) ?? false);
    }).toList();

    Map<DateTime, List<Message>> groupedMessages = {};
    for (var message in filteredMessages) {
      DateTime date = DateTime(
        message.createdAt.year,
        message.createdAt.month,
        message.createdAt.day,
      );

      if (!groupedMessages.containsKey(date)) {
        groupedMessages[date] = [];
      }
      groupedMessages[date]!.add(message);
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.builder(
        controller: scrollController,
        itemCount: groupedMessages.entries.length,
        itemBuilder: (context, index) {
          final entry = groupedMessages.entries.elementAt(index);
          final messageDate = entry.key;
          final messages = entry.value;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  DateFormat('dd MMMM yyyy').format(messageDate),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
              for (final message in messages) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: MessageBubble(
                    message: message,
                    isMe: message.senderId == currentUserId,
                    searchQuery: searchQuery,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
