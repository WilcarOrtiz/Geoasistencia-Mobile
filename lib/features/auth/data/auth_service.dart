import 'package:dio/dio.dart';
import 'package:geoasistencia/core/network/api_response.dart';
import 'package:geoasistencia/features/auth/data/device_uuid_servoce.dart';
import 'package:geoasistencia/features/auth/domain/auth_response.dart';
import 'package:geoasistencia/core/network/dio_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final _supabase = Supabase.instance.client;
  final _dio = DioClient.instance;

  Future<AuthData> login(String email, String password) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final session = response.session;

    if (session == null) {
      throw Exception('No se pudo iniciar sesión');
    }

    final deviceId = DeviceService.deviceId;
    print('📱 deviceId antes de la petición: $deviceId'); // ← aquí

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
      throw Exception(apiResponse.message);
    }

    return apiResponse.data!;
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
}
