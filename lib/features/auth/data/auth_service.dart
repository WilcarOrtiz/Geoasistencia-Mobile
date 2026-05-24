import 'package:dio/dio.dart';
import 'package:geoasistencia/core/network/api_exception.dart';
import 'package:geoasistencia/core/network/api_response.dart';
import 'package:geoasistencia/core/network/dio_client.dart';
import 'package:geoasistencia/features/auth/data/device_uuid_servoce.dart';
import 'package:geoasistencia/features/auth/domain/auth_response.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final _supabase = Supabase.instance.client;
  final _dio = DioClient.instance;

  Future<AuthData> login(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session == null) {
        throw ApiException('No se pudo iniciar sesión');
      }
    } on AuthException catch (e) {
      throw ApiException(e.message);
    }

    try {
      final deviceId = DeviceService.deviceId;

      final res = await _dio.get(
        'user/me',
        options: Options(
          headers: {if (deviceId != null) 'x-device-id': deviceId},
        ),
      );

      final apiResponse = ApiResponse<AuthData>.fromJson(
        res.data,
        (data) => AuthData.fromJson(data),
      );

      if (!apiResponse.ok || apiResponse.data == null) {
        throw ApiException(apiResponse.message);
      }

      return apiResponse.data!;
    } on DioException catch (e) {
      print('STATUS: ${e.response?.statusCode}');
      print('DATA: ${e.response?.data}');

      print('TYPE: ${e.type}');
      print('MESSAGE: ${e.message}');
      print('ERROR: ${e.error}');
      print('RESPONSE: ${e.response}');

      final data = e.response?.data;

      if (data is Map && data['message'] != null) {
        final message = data['message'];

        if (message is List) {
          throw ApiException(message.join(', '));
        }

        throw ApiException(message.toString());
      }

      if (e.error != null) {
        throw ApiException(e.error.toString());
      }

      throw ApiException(e.message ?? 'Error del servidor');
    }
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
}
