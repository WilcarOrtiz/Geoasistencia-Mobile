import 'package:geoasistencia/core/network/paginated_response.dart';
import 'package:geoasistencia/features/groups/domain/group.dart';

abstract class GroupRepository {
  Future<PaginatedResponse<Group>> getGrupos({int page = 1, int limit = 10});
}
