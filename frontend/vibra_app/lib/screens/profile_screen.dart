import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibra_app/blocs/auth/auth_bloc.dart';
import 'package:vibra_app/blocs/auth/auth_state.dart';

import '../widgets/custom_app_bar.dart';

class ProfileScreen extends StatelessWidget {
  String getBaseUrl() {
    if (kIsWeb) {
      return 'http://localhost:3000';
    } else {
      return 'http://10.0.2.2:3000';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Profile',
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            final String profileImageUrl = '${getBaseUrl()}${state
                .profilePicture}';

            return Container(
              color: Colors.grey[850],
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        height: 180,
                      ),
                      Positioned(
                        top: 50,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: CircleAvatar(
                            radius: 60,
                            backgroundImage: NetworkImage(profileImageUrl),
                            onBackgroundImageError: (error, stackTrace) {
                              print('Error loading image: $error');
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Expanded( // Aggiungi Expanded qui
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          children: [
                            Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              elevation: 4,
                              margin: const EdgeInsets.symmetric(
                                  vertical: 10.0),
                              color: Colors.lightBlue[100],
                              child: ListTile(
                                leading: Icon(Icons.person),
                                title: const Text('Username'),
                                subtitle: Text(state.username),
                              ),
                            ),
                            Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              elevation: 4,
                              margin: const EdgeInsets.symmetric(
                                  vertical: 10.0),
                              color: Colors.lightBlue[100],
                              child: ListTile(
                                leading: const Icon(Icons.email),
                                title: const Text('Email'),
                                subtitle: Text(state.email),
                              ),
                            ),
                            Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              elevation: 4,
                              margin: const EdgeInsets.symmetric(
                                  vertical: 10.0),
                              color: Colors.lightBlue[100],
                              child: ListTile(
                                leading: const Icon(Icons.phone),
                                title: const Text('Phone'),
                                subtitle: Text(state.phone),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('User not logged in.'));
          }
        },
      ),
    );
  }
}