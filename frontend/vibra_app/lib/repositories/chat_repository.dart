import 'package:dio/dio.dart';
import 'package:vibra_app/models/chat.dart';

class ChatRepository {
  final Dio _dio;

  ChatRepository({Dio? dio}) : _dio = dio ?? Dio();

  Future<List<Chat>> getChatsByUserId(String userId) async {
    try {
      final response = await _dio.get('/chats/user/$userId');
      if (response.data is List) {
        final List<dynamic> data = response.data;
        return data.map((chatJson) {
          if (chatJson is Map<String, dynamic>) {
            try {
              return Chat.fromJson(chatJson);
            } catch (e) {
              print("Error parsing chat JSON: $chatJson");
              rethrow;
            }
          } else {
            throw Exception('Invalid data format for Chat');
          }
        }).toList();
      } else {
        throw Exception('Invalid response format');
      }
    } catch (error) {
      print('Error fetching chats: $error');
      throw Exception('Failed to load chats: $error');
    }
  }


  Future<Chat> createChat(Chat chat) async {
    try {
      final data = chat.toJson();
      data.remove('_id');
      data.remove('createdAt');
      data.remove('updatedAt');

      final response = await _dio.post('/chats', data: data);
      final chatData = response.data as Map<String, dynamic>;

      final chatId = chatData['_id'];

      return await getChatById(chatId);
    } on DioException catch (dioError) {
      print('Request failed with status: ${dioError.response?.statusCode}');
      print('Response data: ${dioError.response?.data}');
      throw Exception('Failed to create chat: ${dioError.response?.data}');
    } catch (e) {
      throw Exception('Failed to create chat: $e');
    }
  }


  Future<Chat> getChatById(String id) async {
    try {
      final response = await _dio.get('/chats/$id');
      return Chat.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load chat: $e');
    }
  }


  Future<String> deleteChat(String chatId) async {
    try {
      await _dio.delete('/chats/$chatId');
      return chatId;
    } on DioException catch (dioError) {
      print('Request failed with status: ${dioError.response?.statusCode}');
      print('Response data: ${dioError.response?.data}');
      throw Exception('Failed to delete chat: ${dioError.response?.data}');
    } catch (e) {
      throw Exception('Failed to delete chat: $e');
    }
  }

  Future<void> leaveGroupChat(String chatId, String userId, String username, String phone, String? profilePicture) async {
    final response = await _dio.post(
      '/chats/$chatId/leave',
      data: {
        'userId': userId,
        'username': username,
        'phone': phone,
        'profilePicture': profilePicture,
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to leave group chat');
    }
  }

  Future<void> addUserToChat(String chatId, String userId, String username, String phone, String? profilePicture) async {
    final response = await _dio.post('/chats/$chatId/add', data: {
      'userId': userId,
      'username': username,
      'phone': phone,
      'profilePicture': profilePicture,
    });
    if (response.statusCode != 200) {
      throw Exception('Failed to add user to chat');
    }
  }

  Future<List<Chat>> searchChats(String query, String userId) async {
    try {
      final response = await _dio.get('/chats/search', queryParameters: {'query': query, 'userId': userId});
      if (response.data is List) {
        final List<dynamic> data = response.data;
        return data.map((chatJson) {
          if (chatJson is Map<String, dynamic>) {
            try {
              return Chat.fromJson(chatJson);
            } catch (e) {
              print("Error parsing chat JSON: $chatJson");
              return null;
            }
          }
          return null;
        }).whereType<Chat>().toList();
      }
      return [];
    } catch (error) {
      throw Exception('Failed to search chats');
    }
  }

}
