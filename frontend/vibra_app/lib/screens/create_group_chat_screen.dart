import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import '../blocs/chat/chat_bloc.dart';
import '../blocs/user/user_bloc.dart';
import '../blocs/user/user_event.dart';
import '../blocs/user/user_state.dart';
import '../models/chat.dart';
import '../models/participant.dart';
import '../models/user.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/auth_section.dart';
import 'chat_screen.dart';

class CreateGroupChatScreen extends StatefulWidget {
  @override
  _CreateGroupChatScreenState createState() => _CreateGroupChatScreenState();
}

class _CreateGroupChatScreenState extends State<CreateGroupChatScreen> {
  List<User> _users = [];
  final Set<User> _selectedUsers = Set<User>();
  String _chatTitle = '';

  String _completeImageUrl(String path) {
    if (kIsWeb) {
      return 'http://localhost:3000$path';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000$path';
    } else {
      return 'http://localhost:3000$path';
    }
  }

  @override
  void initState() {
    super.initState();
    context.read<UserBloc>().add(GetUsers());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatBloc, ChatState>(
      listener: (context, state) {
        if (state is ChatCreated) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(chat: state.chat),
            ),
          );
        } else if (state is ChatError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to create chat: ${state.message}')),
          );
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'New Group Chat',
          actions: [AuthSection()],
        ),
        body: BlocBuilder<UserBloc, UserState>(
          builder: (context, state) {
            if (state is UserLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is UsersLoaded) {
              _users = state.users;
              return Container(
                color: Colors.grey[850],
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Chat Title',
                          border: OutlineInputBorder(),
                          fillColor: Colors.white,
                          filled: true,
                        ),
                        onChanged: (value) {
                          setState(() {
                            _chatTitle = value;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _users.length,
                        itemBuilder: (context, index) {
                          final user = _users[index];
                          final isSelected = _selectedUsers.contains(user);
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedUsers.remove(user);
                                } else {
                                  _selectedUsers.add(user);
                                }
                              });
                            },
                            child: Card(
                              color: Colors.lightBlue[100],
                              margin: const EdgeInsets.symmetric(
                                  vertical: 5.0, horizontal: 10.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(10.0),
                                title: Text(
                                  user.username,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(user.phone),
                                trailing: isSelected
                                    ? const Icon(Icons.check_circle,
                                    color: Colors.green)
                                    : const Icon(Icons.radio_button_unchecked),
                                tileColor: isSelected
                                    ? Colors.green[100]
                                    : Colors.lightBlue[100],
                                leading: CircleAvatar(
                                  backgroundImage: user.profilePicture != null
                                      ? NetworkImage(
                                      _completeImageUrl(
                                          user.profilePicture!))
                                      : null,
                                  child: user.profilePicture == null
                                      ? Text(user.username[0].toUpperCase())
                                      : null,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            } else if (state is UserError) {
              return Center(
                  child: Text('Failed to load users: ${state.message}'));
            } else {
              return const Center(child: Text('No users available'));
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _createGroupChat(context);
          },
          tooltip: 'Create Group Chat',
          child: const Icon(Icons.check),
        ),
      ),
    );
  }

  Future<void> _createGroupChat(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID not found')),
      );
      return;
    }

    final participants = _selectedUsers.map((user) {
      return Participant(
        userId: user.id,
        username: user.username,
        phone: user.phone,
        profilePicture: user.profilePicture,
        id: user.id,
      );
    }).toList();

    final newChat = Chat(
      id: '',
      title: _chatTitle.isNotEmpty
          ? _chatTitle
          : _generateChatTitle(userId, participants),
      participants: participants,
      messages: [],
    );

    context.read<ChatBloc>().add(CreateChatRequested(chatData: newChat));
  }

  String _generateChatTitle(
      String currentUserId, List<Participant> participants) {
    final otherParticipants = participants
        .where((p) => p.userId != currentUserId)
        .map((p) => p.username)
        .toList();

    return otherParticipants.isNotEmpty
        ? otherParticipants.join(', ')
        : 'Group Chat';
  }


}
