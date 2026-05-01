import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoasistencia/core/constants/app_routes.dart';
import 'package:geoasistencia/features/auth/presentation/providers/role_provider.dart';
import 'package:geoasistencia/features/groups/domain/group.dart';
import 'package:geoasistencia/features/groups/presentation/providers/class_day_provider.dart';

class GroupDetailScreen extends ConsumerWidget {
  final Group group;

  const GroupDetailScreen({super.key, required this.group});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(userRoleProvider);
    final classDays = ref.watch(classDayProvider(group.id));

    return Scaffold(
      appBar: AppBar(title: Text(group.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(group: group),
            const SizedBox(height: 20),
            _Stats(group: group),
            const SizedBox(height: 20),

            _SectionTitle('Información'),
            _InfoRow(Icons.school_outlined, 'Semestre', group.semester.name),
            _InfoRow(
              Icons.calendar_month_outlined,
              'Año',
              '${group.academicYear}',
            ),
            _InfoRow(Icons.person_outline, 'Docente', group.teacher.name),
            _InfoRow(
              Icons.circle,
              'Estado',
              group.isActive ? 'Activo' : 'Inactivo',
              valueColor: group.isActive ? Colors.green : Colors.red,
            ),

            const SizedBox(height: 20),

            _SectionTitle('Días de clase'),
            classDays.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
              data: (days) => Column(
                children: days
                    .map(
                      (d) => _InfoRow(
                        Icons.schedule_outlined,
                        d.dayLabel,
                        '${d.startTime} - ${d.endTime}',
                      ),
                    )
                    .toList(),
              ),
            ),

            const SizedBox(height: 30),

            // BOTONES SEGÚN ROL
            if (role == UserRole.teacher)
              _PrimaryButton(
                text: 'Iniciar llamado a lista',
                icon: Icons.play_arrow,
                onPressed: () => Navigator.pushNamed(
                  context,
                  AppRoutes.openSession,
                  arguments: group.id,
                ),
              )
            else
              Column(
                children: [
                  _PrimaryButton(
                    text: 'Registrar mi asistencia',
                    icon: Icons.check_circle_outline,
                    onPressed: () => Navigator.pushNamed(
                      context,
                      AppRoutes.markAttendance,
                      arguments: group.id, // FIX: groupId requerido
                    ),
                  ),
                  const SizedBox(height: 12),
                  _SecondaryButton(
                    text: 'Ver historial',
                    icon: Icons.history,
                    onPressed: () => Navigator.pushNamed(
                      context,
                      AppRoutes.myAttendance,
                      arguments: group.id,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final Group group;
  const _Header({required this.group});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.secondaryContainer,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(group.code, style: TextStyle(color: theme.colorScheme.primary)),
          const SizedBox(height: 6),
          Text(
            group.name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(group.subject.name),
        ],
      ),
    );
  }
}

class _Stats extends StatelessWidget {
  final Group group;
  const _Stats({required this.group});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(
          icon: Icons.people_outline,
          label: 'Estudiantes',
          value: '${group.totalStudents}/${group.maxStudents}',
        ),
        const SizedBox(width: 12),
        _StatCard(
          icon: Icons.calendar_today_outlined,
          label: 'Sesiones',
          value: '${group.totalSessions}',
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  const _PrimaryButton({
    required this.text,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  const _SecondaryButton({
    required this.text,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(text),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(label),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow(this.icon, this.label, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.grey)),
          const Spacer(),
          Text(value, style: TextStyle(color: valueColor)),
        ],
      ),
    );
  }
}
