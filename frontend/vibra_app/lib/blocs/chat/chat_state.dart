// chat_state.dart
part of 'chat_bloc.dart';

abstract class ChatState extends Equatable {
  @override
  List<Object> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final Chat chat;

  ChatLoaded({required this.chat});

  @override
  List<Object> get props => [chat];
}

class ChatsLoaded extends ChatState {
  final List<Chat> chats;

  ChatsLoaded({required this.chats});

  @override
  List<Object> get props => [chats];
}

class ChatSearchResult extends ChatState {
  final List<Chat> chats;

  ChatSearchResult({required this.chats});

  @override
  List<Object> get props => [chats];
}

class ChatCreated extends ChatState {
  final Chat chat;

  ChatCreated({required this.chat});

  @override
  List<Object> get props => [chat];
}

class UsersSelected extends ChatState {
  final List<User> selectedUsers;

  UsersSelected({required this.selectedUsers});

  @override
  List<Object> get props => [selectedUsers];
}

class ChatError extends ChatState {
  final String message;

  ChatError({required this.message});

  @override
  List<Object> get props => [message];
}
