import 'dart:io';

import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthLoggedIn extends AuthEvent {
  final String email;
  final String password;

  AuthLoggedIn(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

class AuthLoggedOut extends AuthEvent {}

class AuthCheckRequested extends AuthEvent {}

class AuthRegisterRequested extends AuthEvent {
  final String username;
  final String phone;
  final String email;
  final String password;
  final File? profilePicture;

  AuthRegisterRequested({
    required this.username,
    required this.phone,
    required this.email,
    required this.password,
    this.profilePicture,
  });

  @override
  List<Object?> get props => [username, phone, email, password, profilePicture];
}

