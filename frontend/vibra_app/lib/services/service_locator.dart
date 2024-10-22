import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get_it/get_it.dart';
import 'package:vibra_app/blocs/auth/auth_bloc.dart';
import 'package:vibra_app/blocs/user/user_bloc.dart';
import 'package:vibra_app/repositories/auth_repository.dart';
import 'package:vibra_app/repositories/chat_repository.dart';
import 'package:vibra_app/repositories/message_repository.dart';
import 'package:vibra_app/repositories/user_repository.dart';
import 'package:vibra_app/services/api_service.dart';
import 'package:vibra_app/services/socket_service.dart';
import '../blocs/chat/chat_bloc.dart';

final GetIt getIt = GetIt.instance;

void setupServiceLocator() {
  // Registrare le istanze dei servizi
  getIt.registerLazySingleton(() => ApiService());
  getIt.registerLazySingleton(() => SocketService());

  // Registrare i repository
  getIt.registerFactory(() => AuthRepository(getIt<ApiService>().dio));
  getIt.registerFactory(() => ChatRepository(dio: getIt<ApiService>().dio));
  getIt.registerFactory(() => UserRepository(dio: getIt<ApiService>().dio));
  getIt.registerFactory(() => MessageRepository(getIt<ApiService>()));

  // Registrare il blocco
  getIt.registerFactory<UserBloc>(() => UserBloc(userRepository: getIt<UserRepository>()));
  getIt.registerFactory<AuthBloc>(() => AuthBloc(authRepository: getIt<AuthRepository>()));
  getIt.registerFactory(() => ChatBloc(
    chatRepository: getIt<ChatRepository>(),
    userRepository: getIt<UserRepository>(),
    messageRepository: getIt<MessageRepository>(),
    socketService: getIt<SocketService>(),
  ));
}
