import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/user/user_bloc.dart';
import '../blocs/user/user_event.dart';
import '../blocs/user/user_state.dart';
import '../models/user.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/auth_section.dart';

class SelectUserScreen extends StatefulWidget {
  @override
  _SelectUserScreenState createState() => _SelectUserScreenState();
}

class _SelectUserScreenState extends State<SelectUserScreen> {
  List<User> _users = [];

  @override
  void initState() {
    super.initState();
    context.read<UserBloc>().add(GetUsers());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Select User',
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
                      Navigator.pop(context, user);
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
                          style: TextStyle(fontWeight: FontWeight.bold),
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
            return Center(child: Text('Failed to load users: ${state.message}'));
          } else {
            return const Center(child: Text('No users available'));
          }
        },
      ),
    );
  }

  String _completeImageUrl(String path) {
    return 'http://10.0.2.2:3000$path';
  }
}
