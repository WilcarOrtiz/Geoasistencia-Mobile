import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoasistencia/core/constants/app_routes.dart';
import 'package:geoasistencia/core/theme/app_theme.dart';
import 'package:geoasistencia/features/auth/presentation/providers/role_provider.dart';
import 'package:geoasistencia/features/groups/domain/group.dart';

class GroupsListView extends ConsumerWidget {
  final List<Group> grupos;

  const GroupsListView({super.key, required this.grupos});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(userRoleProvider);
    final isStudent = role == UserRole.student;

    if (grupos.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: grupos
          .map(
            (g) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _GroupCard(group: g, isStudent: isStudent),
            ),
          )
          .toList(),
    );
  }
}

class _GroupCard extends StatelessWidget {
  final Group group;
  final bool isStudent;

  const _GroupCard({required this.group, required this.isStudent});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () =>
          Navigator.pushNamed(context, AppRoutes.groupDetail, arguments: group),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header colored strip ─────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primarySurface, Color(0xFFF0FAF4)],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    borderRadius: AppRadius.fullBr,
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.25),
                    ),
                  ),
                  child: Text(
                    group.code,
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: group.isActive
                        ? AppColors.successSurface
                        : AppColors.absentSurface,
                    borderRadius: AppRadius.fullBr,
                  ),
                  child: Icon(
                    group.isActive ? Icons.circle : Icons.circle_outlined,
                    size: 8,
                    color: group.isActive
                        ? AppColors.present
                        : AppColors.absent,
                  ),
                ),
              ],
            ),
          ),

          // ── Body ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(group.name, style: AppTextStyles.h2),
                const SizedBox(height: 2),
                Text(group.subject.name, style: AppTextStyles.bodyMd),
                const SizedBox(height: 12),

                Row(
                  children: [
                    InfoChip(
                      icon: Icons.people_outline_rounded,
                      label: isStudent
                          ? 'Grupo'
                          : '${group.totalStudents} estudiantes',
                    ),
                    const SizedBox(width: 8),
                    InfoChip(
                      icon: Icons.calendar_today_outlined,
                      label: '${group.totalSessions} sesiones',
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textMuted,
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
