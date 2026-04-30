import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoasistencia/features/auth/presentation/providers/auth_provider.dart';

enum UserRole { teacher, student, admin, unknown }

final userRoleProvider = Provider<UserRole>((ref) {
  final authData = ref.watch(authProvider).asData?.value;

  if (authData == null) return UserRole.unknown;

  final roles = authData.roles.map((r) => r.name.toUpperCase().trim()).toList();

  print('Roles recibidos: $roles'); // puedes borrarlo después

  if (roles.contains('TEACHER')) return UserRole.teacher;
  if (roles.contains('ADMIN')) return UserRole.admin;
  if (roles.contains('STUDENT')) return UserRole.student;
  return UserRole.unknown;
});
