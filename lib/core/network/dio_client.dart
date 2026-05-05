import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DioClient {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://6bqlsbfc-3001.use2.devtunnels.ms/api/',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  static Dio get instance => _dio;

  static void init() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final session = Supabase.instance.client.auth.currentSession;
          final token = session?.accessToken;

          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          handler.next(options);
        },
      ),
    );
  }
}
