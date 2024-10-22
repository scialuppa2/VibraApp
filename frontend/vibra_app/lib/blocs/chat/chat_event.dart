part of 'chat_bloc.dart';

abstract class ChatEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class CreateChatRequested extends ChatEvent {
  final Chat chatData;

  CreateChatRequested({required this.chatData});

  @override
  List<Object> get props => [chatData];
}

class DeleteChatRequested extends ChatEvent {
  final String chatId;

  DeleteChatRequested({required this.chatId});

  @override
  List<Object> get props => [chatId];
}

class UndoDeleteChatRequested extends ChatEvent {
  final Chat chat;

  UndoDeleteChatRequested({required this.chat});

  @override
  List<Object> get props => [chat];
}

class GetChatByIdRequested extends ChatEvent {
  final String id;

  GetChatByIdRequested({required this.id});

  @override
  List<Object> get props => [id];
}

class FetchUserChats extends ChatEvent {
  final String userId;

  FetchUserChats({required this.userId});

  @override
  List<Object> get props => [userId];
}

class SelectParticipants extends ChatEvent {
  final List<String> userIds;

  SelectParticipants({required this.userIds});

  @override
  List<Object> get props => [userIds];
}

class SendMessageRequested extends ChatEvent {
  final String chatId;
  final SendMessage message;
  final String senderId;
  final String senderUsername;

  SendMessageRequested({required this.chatId, required this.message, required this.senderId, required this.senderUsername,});

  @override
  List<Object> get props => [chatId, message];
}

class NewMessageReceived extends ChatEvent {
  final Message message;

  NewMessageReceived({required this.message});

  @override
  List<Object> get props => [message];
}

class AddUserToChatRequested extends ChatEvent {
  final String chatId;
  final String userId;
  final String username;
  final String phone;
  final String? profilePicture;

  AddUserToChatRequested({
    required this.chatId,
    required this.userId,
    required this.username,
    required this.phone,
    required this.profilePicture,
  });
}

class LeaveGroupChatRequested extends ChatEvent {
  final String chatId;
  final String userId;
  final String username;
  final String phone;
  final String? profilePicture;


  LeaveGroupChatRequested({required this.chatId, required this.userId, required this.username, required this.phone, required this.profilePicture});

  @override
  List<Object> get props => [chatId, userId];
}

class UndoLeaveGroupChatRequested extends ChatEvent {
  final Chat chat;
  final String userId;
  final String username;
  final String phone;
  final String? profilePicture;

  UndoLeaveGroupChatRequested({required this.chat, required this.userId, required this.username, required this.phone, required this.profilePicture});

  @override
  List<Object> get props => [chat, userId];
}

class SearchChats extends ChatEvent {
  final String query;
  final String userId;

  SearchChats({required this.query, required this.userId});

  @override
  List<Object> get props => [query, userId];
}