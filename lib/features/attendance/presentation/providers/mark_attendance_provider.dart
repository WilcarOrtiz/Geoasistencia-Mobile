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
    state = const AsyncValue.loading();
    try {
      // 2. Escanear BLE y obtener el código emitido por el docente
      //    Si lo recibe → está físicamente cerca (~10 m)
      final sessionCode = await ClassSessionService().getActiveSessionCode(
        groupId,
      );

      if (sessionCode == null) {
        throw Exception('No hay sesión activa en tu grupo.');
      }

      final code = await BleService.scanForCode(sessionCode);

      // 3. GPS del estudiante
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // 4. ID del estudiante desde el estado de auth
      final authData = _ref.read(authProvider).asData?.value;
      final studentId = authData?.user.authId;
      if (studentId == null) throw Exception('Usuario no autenticado');

      // 5. Llamar al backend — valida código + distancia GPS
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

  void reset() => state = const AsyncValue.data(null);
}
