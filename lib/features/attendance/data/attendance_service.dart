import 'package:geoasistencia/core/network/dio_client.dart';
import 'package:geoasistencia/features/attendance/domain/my_attendance.dart';

class AttendanceService {
  final _dio = DioClient.instance;

  Future<MyAttendances> getMyHistory(String groupId) async {
    final response = await _dio.get('/attendances/group/$groupId/my-history');

    final data = response.data['data'];

    final sessions = (data['sessions'] as List)
        .map(
          (s) => MyAttendanceSession(
            sessionId: s['session_id'],
            classTopic: s['class_topic'],
            date: DateTime.parse(s['date']),
            status: s['status'],
            checkInTime: s['check_in_time'],
          ),
        )
        .toList();

    return MyAttendances(
      groupId: data['group_id'],
      totalSessions: data['total_sessions'],
      totalPresent: data['total_present'],
      attendanceRate: (data['attendance_rate'] as num).toDouble(),
      sessions: sessions,
    );
  }

  Future<void> markAttendance({
    required String studentId,
    required String codeClassSession,
    required double latitude,
    required double longitude,
  }) async {
    await _dio.patch(
      '/attendances',
      data: {
        'student_id': studentId,
        'code_class_session': codeClassSession,
        'latitude': latitude,
        'longitude': longitude,
      },
    );
  }
}
