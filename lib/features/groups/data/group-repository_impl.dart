import 'package:geoasistencia/core/network/paginated_response.dart';
import 'package:geoasistencia/features/groups/data/group-service.dart';
import 'package:geoasistencia/features/groups/domain/group-repository.dart';
import 'package:geoasistencia/features/groups/domain/group.dart';

class GroupRepositoryImpl implements GroupRepository {
  final _service = GroupService();

  @override
  Future<PaginatedResponse<Group>> getGrupos({int page = 1, int limit = 10}) {
    return _service.getGrupos(page: page, limit: limit);
  }
}
