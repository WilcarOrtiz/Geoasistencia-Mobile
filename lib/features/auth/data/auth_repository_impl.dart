import 'package:geoasistencia/features/auth/data/auth_service.dart';
import 'package:geoasistencia/features/auth/domain/auth_repository.dart';
import 'package:geoasistencia/features/auth/domain/auth_response.dart';

class AuthRepositoryImpl implements AuthRepository {
  final _service = AuthService();

  @override
  Future<AuthData> login(String email, String password) async {
    return await _service.login(email, password);
  }

  @override
  Future<void> logout() async {
    await _service.logout();
  }
}
