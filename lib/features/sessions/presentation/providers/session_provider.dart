import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:geoasistencia/features/sessions/data/class_session_service.dart';
import 'package:geolocator/geolocator.dart';

final openSessionProvider =
    StateNotifierProvider<OpenSessionNotifier, AsyncValue<String?>>((ref) {
      return OpenSessionNotifier();
    });

class OpenSessionNotifier extends StateNotifier<AsyncValue<String?>> {
  OpenSessionNotifier() : super(const AsyncValue.data(null));

  Future<void> open(String groupId, {String? classTopic}) async {
    state = const AsyncValue.loading();
    try {
      // 1. Pedir permiso y obtener GPS
      final permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Se necesita permiso de ubicación');
      }
      final position = await Geolocator.getCurrentPosition();

      // 2. Llamar al backend
      final code = await ClassSessionService().openSession(
        groupId: groupId,
        latitude: position.latitude,
        longitude: position.longitude,
        classTopic: classTopic,
      );

      state = AsyncValue.data(code);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
