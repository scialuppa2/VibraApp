import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibra_app/repositories/auth_repository.dart';
import '../auth/auth_event.dart';
import '../auth/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoggedIn>(_onAuthLoggedIn);
    on<AuthLoggedOut>(_onAuthLoggedOut);
    on<AuthRegisterRequested>(_onAuthRegisterRequested);

    add(AuthCheckRequested());
  }

  Future<void> _onAuthCheckRequested(AuthCheckRequested event,
      Emitter<AuthState> emit) async {
    try {
      final isAuthenticated = await authRepository.isAuthenticated();

      if (isAuthenticated) {
        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getString('userId') ?? '';
        final username = prefs.getString('username') ?? '';
        final phone = prefs.getString('phone') ?? '';
        final email = prefs.getString('email') ?? '';
        final profilePicture = prefs.getString('profilePicture') ?? '';


        emit(AuthAuthenticated(userId: userId,
            username: username,
            phone: phone,
            email: email,
            profilePicture: profilePicture));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }


  Future<void> _onAuthLoggedIn(AuthLoggedIn event,
      Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final userData = await authRepository.login(event.email, event.password);

      emit(AuthAuthenticated(
          username: userData['username'],
          phone: userData['phone'],
          userId: userData['userId'],
          email: userData['email'],
          profilePicture: userData['profilePicture']
      ));
    } catch (e) {
      emit(AuthError('Failed to login. Please check your email and password.'));
      emit(AuthUnauthenticated());

    }
  }


  Future<void> _onAuthLoggedOut(AuthLoggedOut event,
      Emitter<AuthState> emit) async {
    try {
      await authRepository.logout();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onAuthRegisterRequested(AuthRegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await authRepository.register(
        event.username,
        event.phone,
        event.email,
        event.password,
        event.profilePicture,
      );

      final userData = await authRepository.login(event.email, event.password);

      emit(AuthAuthenticated(
        username: userData['username'],
        phone: userData['phone'],
        userId: userData['userId'],
        email: userData['email'],
        profilePicture: userData['profilePicture'],
      ));
    } catch (e) {
      print(AuthError(e.toString()));
      emit(AuthUnauthenticated());
    }
  }

}
