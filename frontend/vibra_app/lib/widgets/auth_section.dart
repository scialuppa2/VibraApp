import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibra_app/blocs/auth/auth_bloc.dart';
import 'package:vibra_app/blocs/auth/auth_state.dart';
import 'package:vibra_app/blocs/auth/auth_event.dart';
import 'package:vibra_app/blocs/chat/chat_bloc.dart';
import 'package:vibra_app/screens/profile_screen.dart';

class AuthSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          BlocProvider.of<ChatBloc>(context)
              .add(FetchUserChats(userId: state.userId));
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              PopupMenuButton<int>(
                onSelected: (item) => _onSelected(context, item),
                itemBuilder: (context) => [
                  const PopupMenuItem<int>(
                    value: 0,
                    child: Row(
                      children: [
                        Icon(Icons.person, color: Colors.black),
                        SizedBox(width: 8),
                        Text('Profile'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<int>(
                    value: 1,
                    child: Row(
                      children: [
                        Icon(Icons.settings, color: Colors.black),
                        SizedBox(width: 8),
                        Text('Settings'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<int>(
                    value: 2,
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.black),
                        SizedBox(width: 8),
                        Text('Logout'),
                      ],
                    ),
                  ),
                ],
                icon: CircleAvatar(
                  backgroundColor: Colors.grey[850],
                  child: Text(
                    state.username.isNotEmpty ? state.username[0] : '',
                    style: TextStyle(color: Colors.lightBlue[100], fontSize: 24),
                  ),
                ),
              ),
            ],
          );
        } else {
          return const Center(child: Text('Please log in.'));
        }
      },
    );
  }

  void _onSelected(BuildContext context, int item) {
    switch (item) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfileScreen()),
        );
        break;
      case 1:
        // Action for the settings
        break;
      case 2:
        BlocProvider.of<AuthBloc>(context).add(AuthLoggedOut());
        break;
    }
  }
}
