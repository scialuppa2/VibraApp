abstract class MessageEvent {}

class LoadMessages extends MessageEvent {
  final String chatId;

  LoadMessages({required this.chatId});
}

class CreateMessage extends MessageEvent {
  final String content;
  final String chatId;
  final String senderId;
  final String senderUsername;
  final String? filePath;

  CreateMessage({
    required this.content,
    required this.chatId,
    required this.senderId,
    required this.senderUsername,
    this.filePath,
  });
}

class SearchMessages extends MessageEvent {
  final String chatId;
  final String query;

  SearchMessages({required this.chatId, required this.query});
}

