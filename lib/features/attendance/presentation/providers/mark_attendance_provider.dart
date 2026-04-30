import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:geoasistencia/core/services/ble_service.dart';
import 'package:geoasistencia/features/attendance/data/attendance_service.dart';
import 'package:geoasistencia/features/auth/presentation/providers/auth_provider.dart';
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
    StateNotifierProvider<
      MarkAttendanceNotifier,
      AsyncValue<AttendanceResult?>
    >((ref) => MarkAttendanceNotifier(ref));

class MarkAttendanceNotifier
    extends StateNotifier<AsyncValue<AttendanceResult?>> {
  final Ref _ref;
  MarkAttendanceNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<void> mark() async {
    state = const AsyncValue.loading();
    try {
      // 1. Escanear BLE
      final code = await BleService.scanForCode();

      // 2. GPS del estudiante
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // 3. ID del estudiante desde authData
      final authData = _ref.read(authProvider).asData?.value;
      final studentId = authData?.user.authId;
      if (studentId == null) throw Exception('Usuario no autenticado');

      // 4. Llamar al backend
      await AttendanceService().markAttendance(
        studentId: studentId,
        codeClassSession: code,
        latitude: pos.latitude,
        longitude: pos.longitude,
      );

      state = AsyncValue.data(
        AttendanceResult(
          latitude: pos.latitude,
          longitude: pos.longitude,
          markedAt: DateTime.now(),
        ),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
