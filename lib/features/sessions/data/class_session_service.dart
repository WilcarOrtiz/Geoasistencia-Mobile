import 'package:geoasistencia/core/network/dio_client.dart';

class ClassSessionService {
  final _dio = DioClient.instance;

  Future<String> openSession({
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
    return res.data['code_class_session'] as String;
  }
}
