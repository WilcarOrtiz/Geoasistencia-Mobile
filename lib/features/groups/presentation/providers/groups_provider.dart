// groups_provider.dart
//
// IMPORTANTE: Este provider observa authProvider para que cuando el usuario
// cambie (logout/login), los grupos se recarguen automáticamente con los
// datos del nuevo usuario y no persistan datos del anterior.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoasistencia/core/network/paginated_response.dart';
import 'package:geoasistencia/features/auth/presentation/providers/auth_provider.dart';
import 'package:geoasistencia/features/groups/data/group-service.dart';
import 'package:geoasistencia/features/groups/domain/group.dart';

final groupsProvider = FutureProvider<PaginatedResponse<Group>>((ref) {
  final auth = ref.watch(authProvider);
  final user = auth.asData?.value;

  if (user == null) {
    return Future.value(
      PaginatedResponse<Group>(data: [], total: 0, limit: 10, page: 1),
    );
  }

  return GroupService().getGrupos();
});
