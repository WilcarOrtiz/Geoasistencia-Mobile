import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:geoasistencia/core/services/ble_service.dart';
import 'package:geoasistencia/features/sessions/data/class_session_service.dart';
import 'package:geoasistencia/features/sessions/domain/session_state.dart';
import 'package:geolocator/geolocator.dart';

final openSessionProvider =
    StateNotifierProvider<OpenSessionNotifier, OpenSessionState>(
      (_) => OpenSessionNotifier(),
    );

class OpenSessionNotifier extends StateNotifier<OpenSessionState> {
  OpenSessionNotifier() : super(const OpenSessionState());

  Future<void> open(String groupId, {String? classTopic}) async {
    state = state.copyWith(status: OpenSessionStatus.loading, error: null);
    try {
      // 2. GPS
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // 3. Crear sesión en el backend
      final result = await ClassSessionService().openSession(
        groupId: groupId,
        latitude: pos.latitude,
        longitude: pos.longitude,
        classTopic: classTopic,
      );

      // 4. Emitir código por BLE para que los alumnos lo reciban
      await BleService.startAdvertising(result.codeClassSession);

      state = state.copyWith(
        status: OpenSessionStatus.active,
        code: result.codeClassSession,
        sessionId: result.sessionId,
      );
    } catch (e) {
      String message = 'Error inesperado';
      if (e is DioException) {
        message = e.error?.toString() ?? message;
      } else {
        message = e.toString();
      }
      state = state.copyWith(status: OpenSessionStatus.error, error: message);
    }
  }

  Future<void> close() async {
    final sessionId = state.sessionId;
    await BleService.stopAdvertising();
    if (sessionId != null) {
      try {
        await ClassSessionService().closeSession(sessionId);
      } catch (_) {}
    }
    state = const OpenSessionState();
  }
}
