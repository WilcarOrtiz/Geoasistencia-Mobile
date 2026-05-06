import 'package:geoasistencia/features/sessions/domain/attendance_record.dart';

abstract class AttendanceSource {
  Stream<List<AttendanceRecord>> watch(String sessionId);
  void dispose();
}
