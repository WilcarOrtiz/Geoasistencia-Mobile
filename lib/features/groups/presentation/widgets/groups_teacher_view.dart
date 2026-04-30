import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoasistencia/core/constants/app_routes.dart';
import 'package:geoasistencia/features/auth/presentation/providers/role_provider.dart';
import 'package:geoasistencia/features/groups/domain/group.dart';

class GroupsListView extends ConsumerWidget {
  final List<Group> grupos;

  const GroupsListView({super.key, required this.grupos});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(userRoleProvider);
    print(role.name);
    final isStudent = role == UserRole.student;

    if (grupos.isEmpty) {
      return const Center(child: Text('No tienes grupos asignados'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: grupos.length,
      itemBuilder: (_, i) {
        final g = grupos[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(child: Text(g.code)),
            title: Text(g.name),
            subtitle: Text(g.subject.name),
            trailing: isStudent
                ? const Icon(Icons.chevron_right)
                : Text('${g.totalStudents} estudiantes'),
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.groupDetail,
              arguments: g,
            ),
          ),
        );
      },
    );
  }
}
