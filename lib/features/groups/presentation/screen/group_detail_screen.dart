import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoasistencia/core/constants/app_routes.dart';
import 'package:geoasistencia/core/theme/app_theme.dart';
import 'package:geoasistencia/features/auth/presentation/providers/auth_provider.dart';
import 'package:geoasistencia/features/auth/presentation/providers/role_provider.dart';
import 'package:geoasistencia/features/groups/domain/group.dart';
import 'package:geoasistencia/features/groups/presentation/providers/class_day_provider.dart';

class GroupDetailScreen extends ConsumerWidget {
  final Group group;
  const GroupDetailScreen({super.key, required this.group});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Redirigir si el usuario cerró sesión
    ref.listen<AsyncValue<dynamic>>(authProvider, (_, next) {
      next.whenData((user) {
        if (user == null && context.mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.login,
            (_) => false,
          );
        }
      });
    });

    // Obtener rol desde authProvider (reactivo)
    final role = ref.watch(userRoleProvider);
    final classDays = ref.watch(classDayProvider(group.id));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: GreenGradientBackground(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              expandedHeight: 200,
              pinned: true,
              leading: Padding(
                padding: const EdgeInsets.all(8),
                child: _BackButton(),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: _GroupHeader(group: group),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _StatsRow(group: group),
                    const SizedBox(height: 24),

                    Text('Información del grupo', style: AppTextStyles.h2),
                    const SizedBox(height: 12),
                    AppCard(
                      child: Column(
                        children: [
                          _InfoRow(
                            icon: Icons.school_outlined,
                            label: 'Semestre',
                            value: group.semester.name,
                          ),
                          _Divider(),
                          _InfoRow(
                            icon: Icons.calendar_month_outlined,
                            label: 'Año académico',
                            value: '${group.academicYear}',
                          ),
                          _Divider(),
                          _InfoRow(
                            icon: Icons.person_outline_rounded,
                            label: 'Docente',
                            value: group.teacher.name,
                          ),
                          _Divider(),
                          _InfoRow(
                            icon: Icons.circle_rounded,
                            label: 'Estado',
                            value: group.isActive ? 'Activo' : 'Inactivo',
                            valueWidget: StatusBadge(
                              label: group.isActive ? 'Activo' : 'Inactivo',
                              color: group.isActive
                                  ? AppColors.present
                                  : AppColors.absent,
                              surfaceColor: group.isActive
                                  ? AppColors.presentSurface
                                  : AppColors.absentSurface,
                              icon: group.isActive
                                  ? Icons.check_circle_rounded
                                  : Icons.cancel_rounded,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    Text('Días de clase', style: AppTextStyles.h2),
                    const SizedBox(height: 12),
                    classDays.when(
                      loading: () => const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                      error: (e, _) => Text(
                        'Error: $e',
                        style: AppTextStyles.bodyMd.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                      data: (days) => AppCard(
                        child: Column(
                          children: List.generate(
                            days.length,
                            (i) => Column(
                              children: [
                                _InfoRow(
                                  icon: Icons.schedule_outlined,
                                  label: days[i].dayLabel,
                                  value:
                                      '${days[i].startTime} – ${days[i].endTime}',
                                ),
                                if (i < days.length - 1) _Divider(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── CTA Buttons según rol ─────────────────
                    // El rol se lee reactivamente de userRoleProvider
                    // que depende de authProvider: si el usuario cambia,
                    // esto se reconstruye con el rol correcto.
                    _RoleButtons(group: group, role: role),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Botones de acción según el rol del usuario actual.
/// Separado en widget para claridad y para que se reconstruya
/// correctamente cuando cambia el rol.
class _RoleButtons extends StatelessWidget {
  final Group group;
  final UserRole role;

  const _RoleButtons({required this.group, required this.role});

  @override
  Widget build(BuildContext context) {
    // Solo mostrar botones si el rol es conocido
    if (role == UserRole.unknown) return const SizedBox.shrink();

    if (role == UserRole.teacher) {
      return AppPrimaryButton(
        label: 'Iniciar llamado a lista',
        icon: Icons.play_arrow_rounded,
        onPressed: () => Navigator.pushNamed(
          context,
          AppRoutes.openSession,
          arguments: group.id,
        ),
      );
    }

    // Estudiante
    return Column(
      children: [
        AppPrimaryButton(
          label: 'Registrar mi asistencia',
          icon: Icons.check_circle_outline_rounded,
          onPressed: () => Navigator.pushNamed(
            context,
            AppRoutes.markAttendance,
            arguments: group.id,
          ),
        ),
        const SizedBox(height: 12),
        AppOutlinedButton(
          label: 'Ver mi historial',
          icon: Icons.history_rounded,
          onPressed: () => Navigator.pushNamed(
            context,
            AppRoutes.myAttendance,
            arguments: group.id,
          ),
        ),
      ],
    );
  }
}

// ── Header ────────────────────────────────────────────────────────

class _GroupHeader extends StatelessWidget {
  final Group group;
  const _GroupHeader({required this.group});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 56,
        20,
        20,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryLight],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: AppRadius.fullBr,
            ),
            child: Text(
              group.code,
              style: AppTextStyles.labelSm.copyWith(color: Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            group.name,
            style: AppTextStyles.displaySm.copyWith(color: Colors.white),
          ),
          Text(
            group.subject.name,
            style: AppTextStyles.bodyMd.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stats Row ─────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final Group group;
  const _StatsRow({required this.group});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.people_outline_rounded,
            label: 'Estudiantes',
            value: '${group.totalStudents}/${group.maxStudents}',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.calendar_today_outlined,
            label: 'Sesiones',
            value: '${group.totalSessions}',
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: AppRadius.smBr,
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(height: 10),
          Text(value, style: AppTextStyles.displaySm),
          Text(label, style: AppTextStyles.bodySm),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Widget? valueWidget;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 17, color: AppColors.textMuted),
          const SizedBox(width: 12),
          Text(label, style: AppTextStyles.bodyMd),
          const Spacer(),
          valueWidget ??
              Text(
                value,
                style: AppTextStyles.labelMd.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, color: AppColors.borderSubtle);
  }
}

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: AppRadius.smBr,
        ),
        child: const Icon(
          Icons.arrow_back_rounded,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }
}
