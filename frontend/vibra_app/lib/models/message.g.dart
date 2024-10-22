// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MessageImpl _$$MessageImplFromJson(Map<String, dynamic> json) =>
    _$MessageImpl(
      id: json['_id'] as String,
      content: json['content'] as String,
      chatId: json['chat_id'] as String,
      senderId: json['sender_id'] as String,
      senderUsername: json['sender_username'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      fileUrl: json['file_url'] as String?,
      originalFileName: json['original_file_name'] as String?,
    );

Map<String, dynamic> _$$MessageImplToJson(_$MessageImpl instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'content': instance.content,
      'chat_id': instance.chatId,
      'sender_id': instance.senderId,
      'sender_username': instance.senderUsername,
      'createdAt': instance.createdAt.toIso8601String(),
      'file_url': instance.fileUrl,
      'original_file_name': instance.originalFileName,
    };

_$SendMessageImpl _$$SendMessageImplFromJson(Map<String, dynamic> json) =>
    _$SendMessageImpl(
      content: json['content'] as String,
      chatId: json['chat_id'] as String,
      senderId: json['sender_id'] as String,
      senderUsername: json['sender_username'] as String,
      fileUrl: json['file_url'] as String?,
    );

Map<String, dynamic> _$$SendMessageImplToJson(_$SendMessageImpl instance) =>
    <String, dynamic>{
      'content': instance.content,
      'chat_id': instance.chatId,
      'sender_id': instance.senderId,
      'sender_username': instance.senderUsername,
      'file_url': instance.fileUrl,
    };
