import 'package:dio/dio.dart';
import 'package:vibra_app/models/message.dart';
import 'package:vibra_app/services/api_service.dart';

class MessageRepository {
  final ApiService _apiService;

  MessageRepository(this._apiService);

  Future<Message> createMessage(
      String content,
      String chatId,
      String senderId,
      String senderUsername, {
        String? filePath,
      }) async {
    try {
      FormData formData = FormData.fromMap({
        'content': content,
        'chat_id': chatId,
        'sender_id': senderId,
        'sender_username': senderUsername,
        if (filePath != null)
          'file': await MultipartFile.fromFile(filePath),
      });

      final response = await _apiService.dio.post('/messages', data: formData);

      if (response.statusCode == 201) {
        return Message.fromJson(response.data);
      } else {
        throw Exception('Failed to create message: ${response.statusMessage}');
      }
    } catch (e) {
      print('Exception caught: $e');
      throw Exception('Failed to create message: $e');
    }
  }



  Future<List<Message>> getMessagesByChatId(String chatId) async {
    try {
      final response = await _apiService.dio.get('/messages/$chatId');

      if (response.statusCode == 200) {
        List<Message> messages = (response.data as List)
            .map((messageJson) => Message.fromJson(messageJson))
            .toList();
        return messages;
      } else {
        throw Exception('Failed to load messages: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Failed to load messages: $e');
    }
  }

  Future<List<Message>> searchMessages(String chatId, String query) async {
    try {
      final response = await _apiService.dio.get('/messages/$chatId/search', queryParameters: {
        'query': query,
      });

      if (response.statusCode == 200) {
        return (response.data as List)
            .map((messageJson) => Message.fromJson(messageJson))
            .toList();
      } else {
        throw Exception('Failed to search messages: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Failed to search messages: $e');
    }
  }

}
