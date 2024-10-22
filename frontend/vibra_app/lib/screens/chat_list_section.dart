import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../blocs/chat/chat_bloc.dart';
import '../models/chat.dart';
import 'chat_screen.dart';

class ChatListSection extends StatelessWidget {
  final String searchQuery;

  const ChatListSection({super.key, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatBloc, ChatState>(
      listener: (context, chatState) {
        if (chatState is ChatError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load chats: ${chatState.message}')),
          );
        }
      },
      builder: (context, chatState) {
        if (chatState is ChatLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (chatState is ChatsLoaded) {
          final chats = chatState.chats.where((chat) {
            final searchLower = searchQuery.toLowerCase();
            final titleMatch = chat.title?.toLowerCase().contains(searchLower) ?? false;

            final participantsMatch = chat.participants.any((participant) {
              return participant.username.toLowerCase().contains(searchLower);
            });

            return titleMatch || participantsMatch;
          }).toList();

          if (chats.isEmpty) {
            return _buildEmptyChatMessage(); // Aggiungi una funzione per il messaggio vuoto
          }

          return FutureBuilder<String?>(
            future: _getUserIdFromPrefs(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError || !snapshot.hasData) {
                return const Center(child: Text('Failed to load user ID'));
              }

              final currentUserId = snapshot.data;

              return Container(
                color: Colors.grey[850],
                child: ListView.builder(
                  itemCount: chats.length,
                  itemBuilder: (context, index) {
                    final chat = chats[index];
                    final chatTitle = _buildChatTitle(chat, currentUserId);

                    final lastMessage = chat.messages.isNotEmpty
                        ? chat.messages.last.content
                        : 'No messages yet';

                    return Dismissible(
                      key: Key(chat.id),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        final user = chat.participants.firstWhere((p) => p.userId == currentUserId);

                        if (_isGroupChat(chat)) {
                          _leaveGroupWithUndo(context, chat, currentUserId!, user.username, user.phone, user.profilePicture);
                        } else {
                          _deleteChatWithUndo(context, chat);
                        }
                      },
                      background: Container(
                        color: Colors.redAccent[400],
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Icon(Icons.delete, color: Colors.grey[100]),
                      ),
                      child: Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                        color: Colors.lightBlue[100],
                        child: ListTile(
                          leading: Icon(Icons.chat_outlined, color: Colors.grey[850]),
                          title: Text(chatTitle, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[850])),
                          subtitle: Text(
                            lastMessage.length > 40 ? '${lastMessage.substring(0, 40)}...' : lastMessage,
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(chat: chat),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        } else {
          return const Center(child: Text('Unexpected state'));
        }
      },
    );
  }

  Widget _buildEmptyChatMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             Icon(Icons.chat_outlined, size: 80, color: Colors.lightBlue[100]),
            const SizedBox(height: 16),
            Text(
              "Non ci sono chat",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.lightBlue[100],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Inizia una nuova conversazione!",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _getUserIdFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  void _deleteChatWithUndo(BuildContext context, Chat chat) {
    final chatBloc = BlocProvider.of<ChatBloc>(context);
    chatBloc.add(DeleteChatRequested(chatId: chat.id));

    final snackBar = SnackBar(
      content: const Text('Chat eliminata'),
      action: SnackBarAction(
        label: 'Annulla',
        onPressed: () {
          chatBloc.add(UndoDeleteChatRequested(chat: chat));
        },
      ),
      duration: const Duration(seconds: 5),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _leaveGroupWithUndo(BuildContext context, Chat chat, String userId, String username, String phone, String? profilePicture) {
    final chatBloc = BlocProvider.of<ChatBloc>(context);
    chatBloc.add(LeaveGroupChatRequested(
      chatId: chat.id,
      userId: userId,
      username: username,
      phone: phone,
      profilePicture: profilePicture,
    ));

    final snackBar = SnackBar(
      content: const Text('Sei uscito dal gruppo'),
      action: SnackBarAction(
        label: 'Annulla',
        onPressed: () {
          chatBloc.add(UndoLeaveGroupChatRequested(
            chat: chat,
            userId: userId,
            username: username,
            phone: phone,
            profilePicture: profilePicture,
          ));
        },
      ),
      duration: const Duration(seconds: 5),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  bool _isGroupChat(Chat chat) {
    return chat.participants.length >= 3;
  }

  String _buildChatTitle(Chat chat, String? currentUserId) {
    if (_isGroupChat(chat)) {
      return chat.title ?? 'Group Chat';
    } else {
      final otherParticipants = chat.participants
          .where((p) => p.userId != currentUserId)
          .toList();
      return otherParticipants.isNotEmpty
          ? otherParticipants.map((p) => p.username).join(', ')
          : 'Unknown';
    }
  }
}
