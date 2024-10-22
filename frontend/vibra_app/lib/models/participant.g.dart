// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'participant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ParticipantImpl _$$ParticipantImplFromJson(Map<String, dynamic> json) =>
    _$ParticipantImpl(
      userId: json['user_id'] as String,
      username: json['username'] as String,
      phone: json['phone'] as String,
      profilePicture: json['profilePicture'] as String?,
      id: json['_id'] as String,
    );

Map<String, dynamic> _$$ParticipantImplToJson(_$ParticipantImpl instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'username': instance.username,
      'phone': instance.phone,
      'profilePicture': instance.profilePicture,
      '_id': instance.id,
    };
