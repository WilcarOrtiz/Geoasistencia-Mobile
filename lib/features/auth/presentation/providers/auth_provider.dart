import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:geoasistencia/core/network/api_exception.dart';
import 'package:geoasistencia/features/auth/data/auth_service.dart';
import 'package:geoasistencia/features/auth/domain/auth_response.dart';
import 'package:geoasistencia/core/utils/storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<AuthData?>>(
  (ref) {
    return AuthNotifier(AuthService());
  },
);

class AuthNotifier extends StateNotifier<AsyncValue<AuthData?>> {
  final AuthService _service;

  AuthNotifier(this._service) : super(const AsyncValue.data(null)) {
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final session = Supabase.instance.client.auth.currentSession;

    // Solo intentar restaurar si hay sesión activa
    if (session == null) return;

    // Poner loading solo en este caso
    state = const AsyncValue.loading();

    try {
      final user = await _service.getCurrentUser();
      state = AsyncValue.data(user);
    } catch (_) {
      state = const AsyncValue.data(null);
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();

    try {
      // ✅ NO limpiar todo el storage aquí — borra el deviceId
      // Solo limpiar datos específicos del usuario anterior si los hubiera

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

    // Guardar deviceId antes de limpiar
    final deviceId = StorageService.getData('device_id');

    await StorageService.clear();

    // Restaurar deviceId después de limpiar
    if (deviceId != null) {
      await StorageService.saveData('device_id', deviceId);
    }

    state = const AsyncValue.data(null);
  }

  /// Refresca los datos del usuario (roles, perfil) sin hacer login.
  /// Útil después de cambios de rol o actualización de perfil.
  Future<void> refreshUser() async {
    try {
      final user = await _service.getCurrentUser();
      if (user != null) {
        state = AsyncValue.data(user);
      }
    } catch (_) {}
  }
}
