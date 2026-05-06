import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:geoasistencia/core/services/ble_service.dart';
import 'package:geoasistencia/core/services/permission_service.dart';
import 'package:geoasistencia/features/attendance/data/attendance_service.dart';
import 'package:geoasistencia/features/auth/presentation/providers/auth_provider.dart';
import 'package:geoasistencia/features/sessions/data/class_session_service.dart';
import 'package:geolocator/geolocator.dart';

class AttendanceResult {
  final double latitude;
  final double longitude;
  final DateTime markedAt;

  const AttendanceResult({
    required this.latitude,
    required this.longitude,
    required this.markedAt,
  });
}

final markAttendanceProvider =
    StateNotifierProvider.family<
      MarkAttendanceNotifier,
      AsyncValue<AttendanceResult?>,
      String
    >((ref, groupId) => MarkAttendanceNotifier(ref, groupId));

class MarkAttendanceNotifier
    extends StateNotifier<AsyncValue<AttendanceResult?>> {
  final Ref _ref;
  final String groupId;

  MarkAttendanceNotifier(this._ref, this.groupId)
    : super(const AsyncValue.data(null));

  Future<void> mark() async {
    print('🚀 [MARK] Inicio proceso de asistencia');
    state = const AsyncValue.loading();

    try {
      // 1. Obtener código de sesión activa
      print('🔎 [STEP 1] Buscando sesión activa...');
      final sessionCode = await ClassSessionService().getActiveSessionCode(
        groupId,
      );
      print('📦 [STEP 1] sessionCode: $sessionCode');

      if (sessionCode == null) {
        print('❌ [STEP 1] No hay sesión activa');
        throw Exception('No hay sesión activa en tu grupo.');
      }

      // 2. Escanear BLE
      print('📡 [STEP 2] Escaneando BLE...');
      final code = await BleService.scanForCode(sessionCode);
      print('📡 [STEP 2] Código recibido por BLE: $code');

      // 3. GPS
      print('📍 [STEP 3] Obteniendo ubicación...');
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      print('📍 [STEP 3] Lat: ${pos.latitude}, Lng: ${pos.longitude}');

      // 4. Usuario
      print('👤 [STEP 4] Obteniendo usuario...');
      final authData = _ref.read(authProvider).asData?.value;
      final studentId = authData?.user.authId;

      print('👤 [STEP 4] studentId: $studentId');

      if (studentId == null) {
        print('❌ [STEP 4] Usuario no autenticado');
        throw Exception('Usuario no autenticado');
      }

      // 5. Backend
      print('🌐 [STEP 5] Enviando asistencia al backend...');
      await AttendanceService().markAttendance(
        studentId: studentId,
        codeClassSession: code,
        latitude: pos.latitude,
        longitude: pos.longitude,
      );

      print('✅ [STEP 5] Asistencia registrada correctamente');

      state = AsyncValue.data(
        AttendanceResult(
          latitude: pos.latitude,
          longitude: pos.longitude,
          markedAt: DateTime.now(),
        ),
      );
    } catch (e, st) {
      print('💥 [ERROR] $e');
      print('📚 [STACK] $st');

      state = AsyncValue.error(e, st);
    }
  }

  void reset() => state = const AsyncValue.data(null);
}
