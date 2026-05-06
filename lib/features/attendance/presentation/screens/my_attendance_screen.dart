import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoasistencia/features/attendance/domain/my_attendance.dart';
import 'package:geoasistencia/features/attendance/presentation/providers/attendance_provider.dart';

class MyAttendanceScreen extends ConsumerWidget {
  final String groupId;

  const MyAttendanceScreen({super.key, required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myAttendanceProvider(groupId));

    return Scaffold(
      appBar: AppBar(title: const Text('Mi historial')),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
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
    return Column(
      children: [
        _SummaryCard(data: data),
        const Divider(height: 1),
        Expanded(child: _SessionList(sessions: data.sessions)),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final MyAttendances data;
  const _SummaryCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final rate = data.attendanceRate;

    final color = rate >= 80
        ? Colors.green
        : rate >= 60
        ? Colors.orange
        : Colors.red;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: _StatChip(
              label: 'Sesiones',
              value: '${data.totalSessions}',
              icon: Icons.calendar_today_outlined,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatChip(
              label: 'Presente',
              value: '${data.totalPresent}',
              icon: Icons.check_circle_outline,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatChip(
              label: 'Asistencia',
              value: '${rate.toStringAsFixed(0)}%',
              icon: Icons.pie_chart_outline,
              valueColor: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
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
    // 👇 opcional: ordenar por fecha más reciente primero
    final sorted = [...sessions]..sort((a, b) => b.date.compareTo(a.date));

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: sorted.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) => _SessionTile(session: sorted[i]),
    );
  }
}

class _SessionTile extends StatelessWidget {
  final MyAttendanceSession session;

  const _SessionTile({required this.session});

  Color get _statusColor => switch (session.status) {
    'PRESENT' => Colors.green,
    'LATE' => Colors.orange,
    _ => Colors.red,
  };

  IconData get _statusIcon => switch (session.status) {
    'PRESENT' => Icons.check_circle,
    'LATE' => Icons.watch_later,
    _ => Icons.cancel,
  };

  String get _statusLabel => switch (session.status) {
    'PRESENT' => 'Presente',
    'LATE' => 'Tarde',
    _ => 'Ausente',
  };

  String get _formattedDate {
    final d = session.date;
    return '${d.day}/${d.month}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(_statusIcon, color: _statusColor),

        // 👇 ahora solo fecha
        title: Text(_formattedDate),

        // 👇 hora (si existe)
        subtitle: session.checkInTime != null
            ? Text('Hora: ${session.checkInTime}')
            : null,

        // 👇 estado
        trailing: Text(
          _statusLabel,
          style: TextStyle(color: _statusColor, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
