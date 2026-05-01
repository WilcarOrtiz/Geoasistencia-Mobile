import 'package:geoasistencia/core/network/dio_client.dart';

/// Resultado que devuelve el backend al crear una sesión
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

  /// Crea la sesión en el backend y retorna id + codeClassSession
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

    final data = res.data as Map<String, dynamic>;

    return OpenSessionResult(
      sessionId: data['id'] as String,
      codeClassSession: data['code_class_session'] as String,
    );
  }

  /// Cierra la sesión (llama a PATCH /class-sessions/:id/close)
  Future<void> closeSession(String sessionId) async {
    await _dio.patch('/class-sessions/$sessionId/close');
  }
}
