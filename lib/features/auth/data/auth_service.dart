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

    return _fetchUserProfile();
  }

  Future<AuthData?> getCurrentUser() async {
    final session = _supabase.auth.currentSession;
    if (session == null) return null;

    try {
      return await _fetchUserProfile();
    } catch (_) {
      return null;
    }
  }

  Future<AuthData> _fetchUserProfile() async {
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
