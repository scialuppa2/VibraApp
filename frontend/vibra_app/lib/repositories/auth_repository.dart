import 'package:dio/dio.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  final Dio _dio;


  AuthRepository(this._dio);

  Future<void> register(String username, String phone, String email, String password, File? profilePicture) async {
    try {
      FormData formData = FormData.fromMap({
        'username': username,
        'phone': phone,
        'email': email,
        'password': password,
      });

      if (profilePicture != null) {
        formData.files.add(MapEntry(
          'profilePicture',
          await MultipartFile.fromFile(profilePicture.path),
        ));
      } else {
        formData.fields.add(const MapEntry(
          'profilePictureUrl', '/uploads/default_profile.jpg',
        ));
      }

      print('FormData: ${formData.fields}');

      await _dio.post('auth/register', data: formData);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Registration failed');
    }
  }




  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post('auth/login', data: {
        'email': email,
        'password': password,
      });

      final prefs = await SharedPreferences.getInstance();

      final token = response.data['token'];
      final userId = response.data['userId'];
      final username = response.data['username'];
      final phone = response.data['phone'];
      final userEmail = response.data['email'];
      final profilePicture = response.data['profilePicture'];

      await prefs.setString('auth_token', token);
      await prefs.setString('userId', userId);
      await prefs.setString('username', username);
      await prefs.setString('phone', phone);
      await prefs.setString('email', userEmail);
      await prefs.setString('profilePicture', profilePicture);

      return {
        'token': token,
        'userId': userId,
        'username': username,
        'phone': phone,
        'email': userEmail,
        'profilePicture': profilePicture,
      };
    } on DioException catch (e) {
      throw Exception(e.response?.data['error'] ?? 'Login failed');
    }
  }

  Future<bool> isAuthenticated() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      return token != null;
    } catch (e) {
      throw Exception('Error checking authentication status');
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('userId');
      await prefs.remove('username');
      await prefs.remove('phone');
      await prefs.remove('email');
      await prefs.remove('profilepicture');
    } catch (e) {
      throw Exception('Error during logout');
    }
  }
}
