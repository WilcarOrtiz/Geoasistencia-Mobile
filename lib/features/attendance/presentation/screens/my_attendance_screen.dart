import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoasistencia/core/theme/app_theme.dart';
import 'package:geoasistencia/features/attendance/domain/my_attendance.dart';
import 'package:geoasistencia/features/attendance/presentation/providers/attendance_provider.dart';

class MyAttendanceScreen extends ConsumerWidget {
  final String groupId;
  const MyAttendanceScreen({super.key, required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myAttendanceProvider(groupId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mi historial'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: state.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) =>
            Center(child: Text('Error: $e', style: AppTextStyles.bodyMd)),
        data: (data) => _Body(data: data),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final MyAttendances data;
  const _Body({required this.data});

  @override
  Widget build(BuildContext context) {
    return GreenGradientBackground(
      child: Column(
        children: [
          _SummarySection(data: data),
          Expanded(child: _SessionList(sessions: data.sessions)),
        ],
      ),
    );
  }
}

class _SummarySection extends StatelessWidget {
  final MyAttendances data;
  const _SummarySection({required this.data});

  @override
  Widget build(BuildContext context) {
    final rate = data.attendanceRate;
    final color = rate >= 80
        ? AppColors.present
        : rate >= 60
        ? AppColors.late
        : AppColors.absent;
    final surfaceColor = rate >= 80
        ? AppColors.presentSurface
        : rate >= 60
        ? AppColors.lateSurface
        : AppColors.absentSurface;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Progress card ────────────────────────────────
          AppCard(
            color: AppColors.primary,
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Asistencia general',
                      style: AppTextStyles.labelMd.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${rate.toStringAsFixed(0)}%',
                      style: AppTextStyles.displayLg.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                SizedBox(
                  width: 72,
                  height: 72,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: rate / 100,
                        strokeWidth: 7,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        valueColor: const AlwaysStoppedAnimation(Colors.white),
                      ),
                      Text(
                        '${rate.toStringAsFixed(0)}%',
                        style: AppTextStyles.labelSm.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.calendar_today_outlined,
                  label: 'Sesiones',
                  value: '${data.totalSessions}',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  icon: Icons.check_circle_outline_rounded,
                  label: 'Presente',
                  value: '${data.totalPresent}',
                  valueColor: AppColors.present,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  icon: Icons.pie_chart_outline_rounded,
                  label: 'Tasa',
                  value: '${rate.toStringAsFixed(0)}%',
                  valueColor: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color? valueColor;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      child: Column(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(height: 6),
          Text(value, style: AppTextStyles.h1.copyWith(color: valueColor)),
          Text(label, style: AppTextStyles.labelSm),
        ],
      ),
    );
  }
}

class _SessionList extends StatelessWidget {
  final List<MyAttendanceSession> sessions;
  const _SessionList({required this.sessions});

  @override
  Widget build(BuildContext context) {
    final sorted = [...sessions]..sort((a, b) => b.date.compareTo(a.date));

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      itemCount: sorted.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) => _SessionTile(session: sorted[i]),
    );
  }
}

class _SessionTile extends StatelessWidget {
  final MyAttendanceSession session;
  const _SessionTile({required this.session});

  StatusBadge get _badge => switch (session.status) {
    'PRESENT' => StatusBadge.present(),
    'LATE' => StatusBadge.late(),
    _ => StatusBadge.absent(),
  };

  String get _formattedDate {
    final d = session.date;
    const months = [
      '',
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];
    return '${d.day} de ${months[d.month]}, ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          // Date block
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_formattedDate, style: AppTextStyles.labelMd),
              if (session.checkInTime != null)
                Text(
                  'Hora: ${session.checkInTime}',
                  style: AppTextStyles.bodySm,
                ),
            ],
          ),
          const Spacer(),
          _badge,
        ],
      ),
    );
  }
}
