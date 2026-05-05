import 'package:geoasistencia/core/network/api_response.dart';
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

  Future<OpenSessionResult> openSession({
    required String groupId,
    required double latitude,
    required double longitude,
    String? classTopic,
  }) async {
    // 🟡 1. ANTES de enviar (qué estás mandando)
    print('📤 [POST] /class-sessions');
    print({
      'group_id': groupId,
      'latitude': latitude,
      'longitude': longitude,
      'class_topic': classTopic,
    });

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

    print('📥 message: ${response.message}');
    print('📥 ok: ${response.ok}');

    final data = response.data!;

    final sessionId = data['id'] as String;
    final code = data['code_class_session'] as String;

    return OpenSessionResult(sessionId: sessionId, codeClassSession: code);
  }

  Future<String?> getActiveSessionCode(String groupId) async {
    final res = await _dio.get('/class-sessions/group/$groupId/active');

    if (res.data == null) return null;

    final data = res.data as Map<String, dynamic>;
    return data['codeClassSession'] as String?;
  }

  Future<void> closeSession(String sessionId) async {
    // 🟡 4. Log al cerrar
    print('🛑 [PATCH] Cerrar sesión: $sessionId');

    await _dio.patch('/class-sessions/$sessionId/close');

    print('✅ Sesión cerrada correctamente');
  }
}
