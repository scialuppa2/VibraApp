import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String username;
  final String phone;
  final String email;
  final String userId;
  final String profilePicture;

  const AuthAuthenticated({
    required this.username,
    required this.phone,
    required this.email,
    required this.userId,
    required this.profilePicture,
  });

  @override
  List<Object> get props => [username, phone, email, userId, profilePicture];

}


class AuthUnauthenticated extends AuthState {}

class AuthRegistering extends AuthState {}

class AuthRegistered extends AuthState{}

class AuthError extends AuthState {
  final String message;

  AuthError(this.message);

  @override
  List<Object> get props => [message];
}
