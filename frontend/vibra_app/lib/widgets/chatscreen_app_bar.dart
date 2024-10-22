import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:vibra_app/models/chat.dart';
import 'auth_wrapper.dart';

class ChatscreenAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Chat chat;
  final String? currentUserId;
  final VoidCallback onAddUserToChat;
  final Function onSearchToggle;

  const ChatscreenAppBar({
    Key? key,
    required this.chat,
    required this.currentUserId,
    required this.onAddUserToChat,
    required this.onSearchToggle,
  }) : super(key: key);

  String getBaseUrl() {
    if (kIsWeb) {
      return 'http://localhost:3000';
    } else {
      return 'http://10.0.2.2:3000';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          if (chat.participants.length < 3)
            CircleAvatar(
              backgroundImage: NetworkImage(_getProfileImageUrl(chat.participants[0].profilePicture)),
              radius: 20.0,
            ),
          const SizedBox(width: 10),
          Expanded(child: _buildChatTitle(chat, currentUserId)),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            onSearchToggle();
          },
        ),
        IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AuthWrapper()),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.person_add),
          onPressed: onAddUserToChat,
        ),
      ],
      automaticallyImplyLeading: false,
      backgroundColor: Colors.lightBlue[100], // Imposta il colore di sfondo
    );
  }

  Widget _buildChatTitle(Chat chat, String? currentUserId) {
    if (chat.participants.length == 2) {
      final otherParticipant = chat.participants
          .firstWhere((participant) => participant.userId != currentUserId);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(otherParticipant.username, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      );
    } else {
      final participantUsernames = chat.participants.map((participant) => participant.username).join(', ');
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            chat.title.isNotEmpty ? chat.title : 'Group Chat',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(
            '($participantUsernames)',
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      );
    }
  }

  String _getProfileImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      imagePath = '/uploads/default_profile.jpg';
    }
    if (imagePath.startsWith('http')) {
      return imagePath;
    } else {
      return '${getBaseUrl()}$imagePath';
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
