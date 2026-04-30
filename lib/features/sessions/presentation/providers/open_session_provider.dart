import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:geoasistencia/core/services/ble_service.dart';
import 'package:geoasistencia/features/sessions/data/class_session_service.dart';
import 'package:geolocator/geolocator.dart';

enum OpenSessionStatus { idle, loading, active, error }

class OpenSessionState {
  final OpenSessionStatus status;
  final String? code;
  final String? error;

  const OpenSessionState({
    this.status = OpenSessionStatus.idle,
    this.code,
    this.error,
  });

  OpenSessionState copyWith({
    OpenSessionStatus? status,
    String? code,
    String? error,
  }) => OpenSessionState(
    status: status ?? this.status,
    code: code ?? this.code,
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
    state = state.copyWith(status: OpenSessionStatus.loading);
    try {
      // 1. GPS — pedir permiso solo si no está concedido
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever) {
        throw Exception('Permiso de ubicación denegado permanentemente');
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // 2. Backend
      final code = await ClassSessionService().openSession(
        groupId: groupId,
        latitude: pos.latitude,
        longitude: pos.longitude,
        classTopic: classTopic,
      );

      // 3. Emitir por BLE
      await BleService.startAdvertising(code);

      state = state.copyWith(status: OpenSessionStatus.active, code: code);
    } catch (e) {
      state = state.copyWith(
        status: OpenSessionStatus.error,
        error: e.toString(),
      );
    }
  }

  Future<void> close() async {
    await BleService.stopAdvertising();
    state = const OpenSessionState();
  }
}
