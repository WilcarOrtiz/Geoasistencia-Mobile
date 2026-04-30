import 'package:geoasistencia/core/network/dio_client.dart';
import 'package:geoasistencia/features/groups/domain/class_day.dart';

class ClassDayService {
  final _dio = DioClient.instance;

  Future<List<ClassDay>> getByGroup(String groupId) async {
    final res = await _dio.get('class-days/group/$groupId');
    final list = res.data['data'] as List;
    return list.map((e) => ClassDay.fromJson(e)).toList();
  }
}
