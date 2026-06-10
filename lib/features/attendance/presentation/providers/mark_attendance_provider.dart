import 'package:flutter/widgets.dart';
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

final markAttendanceProvider = StateNotifierProvider.autoDispose
    .family<MarkAttendanceNotifier, AsyncValue<AttendanceResult?>, String>(
      (ref, groupId) => MarkAttendanceNotifier(ref, groupId),
    );

class MarkAttendanceNotifier
    extends StateNotifier<AsyncValue<AttendanceResult?>> {
  final Ref _ref;
  final String groupId;

  MarkAttendanceNotifier(this._ref, this.groupId)
    : super(const AsyncValue.data(null));

  Future<void> mark() async {
    state = const AsyncValue.loading();

    try {
      final sessionCode = await ClassSessionService().getActiveSessionCode(
        groupId,
      );

      if (sessionCode == null) {
        throw Exception('No hay sesión activa en tu grupo.');
      }

      final code = await BleService.scanForCode(sessionCode);

      // ✅ Verificar que el código BLE coincide con el de la sesión
      if (code != sessionCode) {
        throw Exception('Código BLE no coincide con la sesión activa.');
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final authData = _ref.read(authProvider).asData?.value;
      final studentId = authData?.user.authId;
      if (studentId == null) throw Exception('Usuario no autenticado');

      await AttendanceService().markAttendance(
        studentId: studentId,
        codeClassSession: code,
        latitude: pos.latitude,
        longitude: pos.longitude,
      );

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
      } catch (_) {}

      state = AsyncValue.data(
        AttendanceResult(
          latitude: pos.latitude,
          longitude: pos.longitude,
          markedAt: DateTime.now(),
          address: address,
        ),
      );
    } catch (e, st) {
      debugPrint('[MarkAttendance] ❌ Error: $e');
      debugPrint('[MarkAttendance] StackTrace: $st');
      state = AsyncValue.error(e, st);
    }
  }

  void reset() => state = const AsyncValue.data(null);
}
