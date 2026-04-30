import 'package:geoasistencia/features/auth/domain/auth_response.dart';

abstract class AuthRepository {
  Future<AuthData> login(String email, String password);
  Future<void> logout();
}
