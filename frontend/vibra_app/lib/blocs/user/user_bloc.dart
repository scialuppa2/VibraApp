import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibra_app/blocs/user/user_event.dart';
import 'package:vibra_app/blocs/user/user_state.dart';
import 'package:vibra_app/repositories/user_repository.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository userRepository;

  UserBloc({required this.userRepository}) : super(const UserInitial()) {
    on<FetchUsers>(_onFetchUsers);
    on<GetUsers>(_onGetUsers);
    on<GetUserById>(_onGetUserById);
    on<UpdateUser>(_onUpdateUser);
    on<DeleteUser>(_onDeleteUser);
    on<UserSelected>(_onUserSelected);
    on<UploadProfilePicture>(_onUploadProfilePicture);
  }

  Future<void> _onFetchUsers(FetchUsers event, Emitter<UserState> emit) async {
    emit(const UserLoading());
    try {
      final users = await userRepository.getUsers();
      emit(UsersLoaded(users));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onGetUsers(GetUsers event, Emitter<UserState> emit) async {
    emit(const UserLoading());
    try {
      final users = await userRepository.getUsers();
      emit(UsersLoaded(users));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onGetUserById(GetUserById event, Emitter<UserState> emit) async {
    emit(const UserLoading());
    try {
      final user = await userRepository.getUserById(event.id);
      emit(UserLoaded(user));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onUpdateUser(UpdateUser event, Emitter<UserState> emit) async {
    emit(const UserLoading());
    try {
      final user = await userRepository.updateUser(event.id, event.user);
      emit(UserLoaded(user));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onDeleteUser(DeleteUser event, Emitter<UserState> emit) async {
    emit(const UserLoading());
    try {
      await userRepository.deleteUser(event.id);
      add(FetchUsers());
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onUserSelected(UserSelected event, Emitter<UserState> emit) async {
    emit(const UserLoading());
    try {
      final selectedUsers = await userRepository.getUsersByIds(event.userIds);
      emit(UsersSelected(selectedUsers));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onUploadProfilePicture(UploadProfilePicture event, Emitter<UserState> emit) async {
    emit(const UserLoading());
    try {
      final user = await userRepository.uploadProfilePicture(event.id, event.filePath);
      emit(UserLoaded(user));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }
}
