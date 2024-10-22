import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibra_app/blocs/chat/chat_bloc.dart';
import 'package:vibra_app/blocs/user/user_bloc.dart';
import 'package:vibra_app/blocs/user/user_state.dart';
import 'package:vibra_app/models/chat.dart';
import 'package:vibra_app/models/user.dart';
import 'package:vibra_app/models/participant.dart';
import 'package:vibra_app/widgets/custom_app_bar.dart';
import '../blocs/user/user_event.dart';
import '../widgets/auth_section.dart';
import 'chat_screen.dart';

class CreateChatScreen extends StatefulWidget {
  @override
  _CreateChatScreenState createState() => _CreateChatScreenState();
}

class _CreateChatScreenState extends State<CreateChatScreen> {
  List<User> _users = [];

  @override
  void initState() {
    super.initState();
    context.read<UserBloc>().add(GetUsers());
  }

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
          title: 'New Chat',
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
                child: ListView.builder(
                  itemCount: _users.length,
                  itemBuilder: (context, index) {
                    final user = _users[index];
                    return GestureDetector(
                      onTap: () {
                        _createChat(context, user);
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
                          leading: CircleAvatar(
                            backgroundImage: user.profilePicture != null
                                ? NetworkImage(_completeImageUrl(user.profilePicture!))
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
              );
            } else if (state is UserError) {
              return Center(
                  child: Text('Failed to load users: ${state.message}'));
            } else {
              return const Center(child: Text('No users available'));
            }
          },
        ),
      ),
    );
  }

  Future<void> _createChat(BuildContext context, User selectedUser) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final username = prefs.getString('username');
    final phone = prefs.getString('phone');

    if (userId == null || username == null || phone == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User information not found')),
      );
      return;
    }

    final participants = [
      Participant(
        userId: selectedUser.id,
        username: selectedUser.username,
        phone: selectedUser.phone,
        profilePicture: selectedUser.profilePicture,
        id: selectedUser.id,
      ),
    ];

    final newChat = Chat(
      id: '',
      title: _generateChatTitle(userId, participants),
      participants: participants,
      messages: [],
    );

    context.read<ChatBloc>().add(CreateChatRequested(chatData: newChat));
  }

  String _generateChatTitle(String currentUserId, List<Participant> participants) {
    final otherParticipants = participants
        .where((p) => p.userId != currentUserId)
        .map((p) => p.username)
        .toList();

    return otherParticipants.isNotEmpty ? otherParticipants.join(', ') : 'Chat';
  }

}
