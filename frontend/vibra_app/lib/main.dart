import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibra_app/blocs/auth/auth_bloc.dart';
import 'package:vibra_app/blocs/user/user_bloc.dart';
import 'package:vibra_app/blocs/chat/chat_bloc.dart';
import 'package:vibra_app/services/service_locator.dart';
import 'package:vibra_app/widgets/auth_wrapper.dart';


void main() {
  setupServiceLocator();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => getIt<AuthBloc>(),
        ),
        BlocProvider<UserBloc>(
          create: (context) => getIt<UserBloc>(),
        ),
        BlocProvider<ChatBloc>(
          create: (context) => getIt<ChatBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'Vibra',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: AuthWrapper(),
      ),
    );
  }
}

