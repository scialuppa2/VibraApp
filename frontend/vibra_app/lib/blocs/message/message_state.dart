import '../../models/message.dart';

abstract class MessageState {}

class MessageInitial extends MessageState {}

class MessageLoading extends MessageState {}

class MessagesLoaded extends MessageState {
  final List<Message> messages;

  MessagesLoaded({required this.messages});
}

class MessageError extends MessageState {
  final String message;

  MessageError({required this.message});
}
