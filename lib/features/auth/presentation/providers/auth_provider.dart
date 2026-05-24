import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:geoasistencia/core/network/api_exception.dart';
import 'package:geoasistencia/features/auth/data/auth_service.dart';
import 'package:geoasistencia/features/auth/domain/auth_response.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<AuthData?>>(
  (ref) {
    return AuthNotifier(AuthService());
  },
);

class AuthNotifier extends StateNotifier<AsyncValue<AuthData?>> {
  final AuthService _service;

  AuthNotifier(this._service) : super(const AsyncValue.data(null));

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();

    try {
      final authData = await _service.login(email, password);

      state = AsyncValue.data(authData);
    } on ApiException catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    } catch (e) {
      state = AsyncValue.error(
        ApiException('Error inesperado'),
        StackTrace.current,
      );
    }
  }

  Future<void> logout() async {
    await _service.logout();

    state = const AsyncValue.data(null);
  }
}
