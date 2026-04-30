import 'package:geoasistencia/core/network/api_response.dart';
import 'package:geoasistencia/core/network/dio_client.dart';
import 'package:geoasistencia/core/network/paginated_response.dart';
import 'package:geoasistencia/features/groups/domain/group.dart';

class GroupService {
  final _dio = DioClient.instance;

  Future<PaginatedResponse<Group>> getGrupos({
    int page = 1,
    int limit = 10,
  }) async {
    final res = await _dio.get(
      'class-groups',
      queryParameters: {'page': page, 'limit': limit},
    );

    final apiResponse = ApiResponse<PaginatedResponse<Group>>.fromJson(
      res.data,
      (data) =>
          PaginatedResponse.fromJson(data, (item) => Group.fromJson(item)),
    );

    if (!apiResponse.ok || apiResponse.data == null) {
      throw Exception(apiResponse.message);
    }

    return apiResponse.data!;
  }
}
