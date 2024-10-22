import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibra_app/blocs/auth/auth_bloc.dart';
import 'package:vibra_app/blocs/auth/auth_state.dart';
import 'package:vibra_app/screens/home_screen.dart';
import 'package:vibra_app/screens/login_screen.dart';
import 'package:vibra_app/screens/registration_screen.dart';

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.message}')),
          );
        }
      },
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return HomeScreen();
        } else if (state is AuthUnauthenticated) {
          return LoginScreen();
        } else if (state is AuthRegistering) {
          return RegistrationScreen();
        } else {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}
