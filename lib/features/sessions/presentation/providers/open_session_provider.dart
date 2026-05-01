import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:geoasistencia/core/services/ble_service.dart';
import 'package:geoasistencia/core/services/permission_service.dart';
import 'package:geoasistencia/features/sessions/data/class_session_service.dart';
import 'package:geolocator/geolocator.dart';

enum OpenSessionStatus { idle, loading, active, error }

class OpenSessionState {
  final OpenSessionStatus status;
  final String? code;
  final String? sessionId;
  final String? error;

  const OpenSessionState({
    this.status = OpenSessionStatus.idle,
    this.code,
    this.sessionId,
    this.error,
  });

  OpenSessionState copyWith({
    OpenSessionStatus? status,
    String? code,
    String? sessionId,
    String? error,
  }) => OpenSessionState(
    status: status ?? this.status,
    code: code ?? this.code,
    sessionId: sessionId ?? this.sessionId,
    error: error ?? this.error,
  );
}

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
      state = state.copyWith(
        status: OpenSessionStatus.error,
        error: e.toString(),
      );
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
