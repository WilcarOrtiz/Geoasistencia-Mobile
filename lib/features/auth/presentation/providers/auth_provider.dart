import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:geoasistencia/features/auth/data/auth_service.dart';
import 'package:geoasistencia/features/auth/domain/auth_response.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      state = AsyncValue.data(authData); // ✅ datos y señal juntos
    } on AuthException catch (e) {
      state = AsyncValue.error(e.message, StackTrace.current);
    } catch (e) {
      state = AsyncValue.error(e.toString(), StackTrace.current);
    }
  }

  Future<void> logout() async {
    await _service.logout();
    state = const AsyncValue.data(null);
  }
}
