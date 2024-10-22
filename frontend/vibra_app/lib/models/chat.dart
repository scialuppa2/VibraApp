import 'package:freezed_annotation/freezed_annotation.dart';
import 'message.dart';
import 'participant.dart';

part 'chat.freezed.dart';
part 'chat.g.dart';

@freezed
class Chat with _$Chat {
  const factory Chat({
    @JsonKey(name: '_id') required String id,
    required String title,
    required List<Message> messages,
    required List<Participant> participants,
    @JsonKey(name: 'createdAt') DateTime? createdAt,
    @JsonKey(name: 'updatedAt') DateTime? updatedAt,
  }) = _Chat;

  factory Chat.fromJson(Map<String, dynamic> json) => _$ChatFromJson(json);
}
