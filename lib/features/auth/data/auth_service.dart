import 'package:dio/dio.dart';
import 'package:geoasistencia/core/errors/auth_exceptions.dart';
import 'package:geoasistencia/core/network/api_response.dart';
import 'package:geoasistencia/features/auth/data/device_uuid_servoce.dart';
import 'package:geoasistencia/features/auth/domain/auth_response.dart';
import 'package:geoasistencia/core/network/dio_client.dart';
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
      if (response.session == null) throw const InvalidCredentialsException();
    } on AuthException catch (e) {
      throw InvalidCredentialsException(e.message);
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
        throw UserNotFoundException(apiResponse.message);
      }

      return apiResponse.data!;
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      if (code == 401 || code == 403) throw const UserNotFoundException();
      throw ServerException(e.message ?? 'Error de red');
    }
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
}
