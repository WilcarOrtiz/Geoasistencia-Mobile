import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoasistencia/features/sessions/data/class_session_service.dart';
import 'package:geoasistencia/features/sessions/data/websocket_attendance_source.dart';
import 'package:geoasistencia/features/sessions/domain/attendance_record.dart';
import 'package:geoasistencia/features/sessions/domain/attendance_source.dart';

/// Provider del source de asistencia.
/// Usa WebSocket en lugar de polling para actualizaciones en tiempo real.
final attendanceSourceProvider = Provider<AttendanceSource>((ref) {
  final source = WebSocketAttendanceSource(ClassSessionService());
  ref.onDispose(source.dispose);
  return source;
});

final attendanceProvider =
    StreamProvider.family<List<AttendanceRecord>, String>((ref, sessionId) {
      final source = ref.watch(attendanceSourceProvider);
      return source.watch(sessionId);
    });
