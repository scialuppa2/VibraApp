import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vibra_app/models/user.dart';

part 'participant.freezed.dart';
part 'participant.g.dart';

@freezed
class Participant with _$Participant {
  const factory Participant({
    @JsonKey(name: 'user_id') required String userId,
    required String username,
    required String phone,
    @JsonKey(name: 'profilePicture') String? profilePicture,
    @JsonKey(name: '_id') required String id,
  }) = _Participant;

  factory Participant.fromJson(Map<String, dynamic> json) => _$ParticipantFromJson(json);

  factory Participant.fromUser(User user) {
    return Participant(
      userId: user.id,
      username: user.username,
      phone: user.phone,
      profilePicture: user.profilePicture,
      id: user.id,
    );
  }
}
