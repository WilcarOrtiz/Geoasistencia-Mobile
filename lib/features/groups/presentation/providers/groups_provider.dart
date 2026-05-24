import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoasistencia/core/network/paginated_response.dart';
import 'package:geoasistencia/features/auth/presentation/providers/auth_provider.dart';
import 'package:geoasistencia/features/groups/data/group-repository_impl.dart';
import 'package:geoasistencia/features/groups/domain/group.dart';

final groupsProvider = FutureProvider<PaginatedResponse<Group>>((ref) async {
  ref.watch(authProvider);

  return GroupRepositoryImpl().getGrupos();
});
