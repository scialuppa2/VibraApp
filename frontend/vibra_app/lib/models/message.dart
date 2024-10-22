import 'package:freezed_annotation/freezed_annotation.dart';

part 'message.freezed.dart';
part 'message.g.dart';

@freezed
class Message with _$Message {
  const factory Message({
    @JsonKey(name: '_id') required String id,
    required String content,
    @JsonKey(name: 'chat_id') required String chatId,
    @JsonKey(name: 'sender_id') required String senderId,
    @JsonKey(name: 'sender_username') required String senderUsername,
    @JsonKey(name: 'createdAt') required DateTime createdAt,
    @JsonKey(name: 'file_url') String? fileUrl,
    @JsonKey(name: 'original_file_name') String? originalFileName, // Aggiungi questo campo
  }) = _Message;

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);
}


@freezed
class SendMessage with _$SendMessage {
  const factory SendMessage({
    required String content,
    @JsonKey(name: 'chat_id') required String chatId,
    @JsonKey(name: 'sender_id') required String senderId,
    @JsonKey(name: 'sender_username') required String senderUsername,
    @JsonKey(name: 'file_url') String? fileUrl,
  }) = _SendMessage;

  factory SendMessage.fromJson(Map<String, dynamic> json) => _$SendMessageFromJson(json);
}
