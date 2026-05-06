import 'package:geoasistencia/core/network/api_response.dart';
import 'package:geoasistencia/core/network/dio_client.dart';
import 'package:geoasistencia/features/sessions/domain/attendance_record.dart';

class OpenSessionResult {
  final String sessionId;
  final String codeClassSession;

  const OpenSessionResult({
    required this.sessionId,
    required this.codeClassSession,
  });
}

class ClassSessionService {
  final _dio = DioClient.instance;

  Future<OpenSessionResult> openSession({
    required String groupId,
    required double latitude,
    required double longitude,
    String? classTopic,
  }) async {
    final res = await _dio.post(
      '/class-sessions',
      data: {
        'group_id': groupId,
        'latitude': latitude,
        'longitude': longitude,
        if (classTopic != null) 'class_topic': classTopic,
      },
    );

    final response = ApiResponse<Map<String, dynamic>>.fromJson(
      res.data,
      (json) => json as Map<String, dynamic>,
    );

    final data = response.data!;

    final sessionId = data['id'] as String;
    final code = data['code_class_session'] as String;

    return OpenSessionResult(sessionId: sessionId, codeClassSession: code);
  }

  Future<List<AttendanceRecord>> getAttendances(String sessionId) async {
    final res = await _dio.get('/class-sessions/$sessionId/attendances');

    final response = ApiResponse<List<dynamic>>.fromJson(
      res.data,
      (json) => json as List<dynamic>,
    );

    if (!response.ok || response.data == null) return [];

    return response.data!
        .map((e) => AttendanceRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<String?> getActiveSessionCode(String groupId) async {
    final res = await _dio.get('/class-sessions/group/$groupId/active');

    final response = ApiResponse<Map<String, dynamic>>.fromJson(
      res.data,
      (json) => json as Map<String, dynamic>,
    );

    final data = response.data;

    if (data == null) return null;

    return data['codeClassSession'] as String?;
  }

  Future<void> closeSession(String sessionId) async {
    await _dio.patch('/class-sessions/$sessionId/close');
  }
}
