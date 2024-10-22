import 'package:dio/dio.dart';
import 'package:vibra_app/models/user.dart';
import 'package:vibra_app/services/api_service.dart';

class UserRepository {
  final Dio _dio;

  UserRepository({Dio? dio}) : _dio = dio ?? Dio();


  Future<List<User>> getUsers() async {
    try {
      final response = await _dio.get('/users');
      if (response.data == null || response.data is! List) {
        throw Exception('Unexpected response format');
      }
      List<User> users = (response.data as List)
          .map((userJson) {
        if (userJson == null) {
          throw Exception('User data is null');
        }
        return User.fromJson(userJson as Map<String, dynamic>);
      })
          .toList();
      return users;
    } catch (e) {
      print('Error fetching users: $e');
      throw Exception('Failed to load users');
    }
  }


  Future<User> getUserById(String id) async {
    try {
      final response = await _dio.get('/users/$id');
      return User.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load user');
    }
  }

  Future<User> updateUser(String id, User user) async {
    try {
      final response = await _dio.put('/users/$id', data: user.toJson());
      return User.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update user');
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      await _dio.delete('/users/$id');
    } catch (e) {
      throw Exception('Failed to delete user');
    }
  }

  Future<List<User>> getUsersByIds(List<String> ids) async {
    try {
      final response = await _dio.post(
        '/users/by-ids',
        data: {'ids': ids},
      );
      List<User> users = (response.data as List)
          .map((userJson) => User.fromJson(userJson))
          .toList();
      return users;
    } catch (e) {
      throw Exception('Failed to load users by IDs');
    }
  }

  Future<User> uploadProfilePicture(String id, String filePath) async {
    final formData = FormData.fromMap({
      'profilePicture': await MultipartFile.fromFile(filePath),
    });

    final response = await _dio.post('/users/$id/uploadProfilePicture', data: formData);
    return User.fromJson(response.data);
  }
}
