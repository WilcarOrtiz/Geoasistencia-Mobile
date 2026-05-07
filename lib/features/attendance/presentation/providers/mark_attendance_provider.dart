import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:geoasistencia/core/services/ble_service.dart';
import 'package:geoasistencia/features/attendance/data/attendance_service.dart';
import 'package:geoasistencia/features/auth/presentation/providers/auth_provider.dart';
import 'package:geoasistencia/features/sessions/data/class_session_service.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class AttendanceResult {
  final double latitude;
  final double longitude;
  final DateTime markedAt;
  final String? address;

  const AttendanceResult({
    required this.latitude,
    required this.longitude,
    required this.markedAt,
    this.address,
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
      print('🔎 [STEP 1] Buscando sesión activa...');
      final sessionCode = await ClassSessionService().getActiveSessionCode(
        groupId,
      );
      print('📦 [STEP 1] sessionCode: $sessionCode');

      if (sessionCode == null)
        throw Exception('No hay sesión activa en tu grupo.');

      // Guard: si el notifier fue disposed durante el await, salir
      if (!mounted) return;

      print('📡 [STEP 2] Escaneando BLE...');
      final code = await BleService.scanForCode(sessionCode);
      print('📡 [STEP 2] Código: $code');

      if (!mounted) return; // ← después de CADA await largo

      print('📍 [STEP 3] Obteniendo ubicación...');
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (!mounted) return;

      print('👤 [STEP 4] Obteniendo usuario...');
      final authData = _ref.read(authProvider).asData?.value;
      final studentId = authData?.user.authId;
      if (studentId == null) throw Exception('Usuario no autenticado');

      print('🌐 [STEP 5] Enviando asistencia al backend...');
      await AttendanceService().markAttendance(
        studentId: studentId,
        codeClassSession: code,
        latitude: pos.latitude,
        longitude: pos.longitude,
      );

      if (!mounted) return;

      print('✅ [STEP 5] Asistencia registrada correctamente');
      /*    state = AsyncValue.data(
        AttendanceResult(
          latitude: pos.latitude,
          longitude: pos.longitude,
          markedAt: DateTime.now(),
        ),
      );*/

      // STEP 6 - Geocoding inverso
      String? address;
      try {
        final placemarks = await placemarkFromCoordinates(
          pos.latitude,
          pos.longitude,
        );
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          address = '${p.street}, ${p.locality}, ${p.country}';
        }
      } catch (_) {} // si falla, address queda null, no es crítico

      if (!mounted) return;

      state = AsyncValue.data(
        AttendanceResult(
          latitude: pos.latitude,
          longitude: pos.longitude,
          markedAt: DateTime.now(),
          address: address,
        ),
      );
    } catch (e, st) {
      print('💥 [ERROR] $e');
      print('📚 [STACK] $st');
      if (mounted) state = AsyncValue.error(e, st);
    }
  }

  void reset() => state = const AsyncValue.data(null);
}
