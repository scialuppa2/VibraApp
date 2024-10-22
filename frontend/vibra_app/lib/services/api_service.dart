import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:universal_io/io.dart';
import 'auth_interceptor.dart';

class ApiService {
  late final Dio _dio;

  ApiService() {
    String baseUrl;

    if (kIsWeb) {
      baseUrl = 'http://localhost:3000/api/';
    } else if (Platform.isAndroid) {
      baseUrl = 'http://10.0.2.2:3000/api/';
    } else {
      baseUrl = 'http://localhost:3000/api/';
    }

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: Duration(milliseconds: 5000),
        receiveTimeout: Duration(milliseconds: 3000),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(AuthInterceptor());
  }

  Dio get dio => _dio;
}
