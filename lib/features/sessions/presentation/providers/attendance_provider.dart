import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoasistencia/features/sessions/data/class_session_service.dart';
import 'package:geoasistencia/features/sessions/data/polling_attendance_source.dart';
import 'package:geoasistencia/features/sessions/domain/attendance_record.dart';
import 'package:geoasistencia/features/sessions/domain/attendance_source.dart';

final attendanceSourceProvider = Provider<AttendanceSource>((ref) {
  final source = PollingAttendanceSource(ClassSessionService());
  ref.onDispose(source.dispose);
  return source;
  // 🔜 WebSocket: return WebSocketAttendanceSource(WebSocketService());
});

final attendanceProvider =
    StreamProvider.family<List<AttendanceRecord>, String>((ref, sessionId) {
      final source = ref.watch(attendanceSourceProvider);
      return source.watch(sessionId);
    });
