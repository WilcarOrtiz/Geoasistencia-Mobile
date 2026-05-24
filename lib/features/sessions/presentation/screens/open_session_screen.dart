import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoasistencia/core/theme/app_theme.dart';
import 'package:geoasistencia/core/utils/app_toast.dart';
import 'package:geoasistencia/features/sessions/domain/attendance_record.dart';
import 'package:geoasistencia/features/sessions/domain/session_state.dart';
import 'package:geoasistencia/features/sessions/presentation/providers/attendance_provider.dart';
import 'package:geoasistencia/features/sessions/presentation/providers/open_session_provider.dart';

class OpenSessionScreen extends ConsumerWidget {
  final String groupId;
  const OpenSessionScreen({super.key, required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(openSessionProvider);

    ref.listen(openSessionProvider, (prev, next) {
      if (next.status == OpenSessionStatus.error && next.error != null) {
        AppToast.error(context, next.error!);
      }
    });

    return PopScope(
      canPop: state.status != OpenSessionStatus.loading,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) {
          await ref.read(openSessionProvider.notifier).close();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Llamado a lista'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: state.status == OpenSessionStatus.loading
                ? null
                : () => Navigator.pop(context),
          ),
        ),
        body: GreenGradientBackground(
          child: SafeArea(
            child: switch (state.status) {
              OpenSessionStatus.idle || OpenSessionStatus.error => _IdleView(
                groupId: groupId,
                error: state.error,
              ),
              OpenSessionStatus.loading => const _LoadingView(),
              OpenSessionStatus.active => _ActiveView(
                code: state.code!,
                groupId: groupId,
                sessionId: state.sessionId!,
              ),
            },
          ),
        ),
      ),
    );
  }
}

// ── Idle View ──────────────────────────────────────────────────────

class _IdleView extends ConsumerWidget {
  final String groupId;
  final String? error;
  const _IdleView({required this.groupId, this.error});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: AppRadius.xlBr,
              border: Border.all(
                color: AppColors.primaryMuted.withOpacity(0.4),
              ),
            ),
            child: const Icon(
              Icons.sensors_rounded,
              size: 64,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(height: 32),

          Text('Iniciar llamado a lista', style: AppTextStyles.displaySm),
          const SizedBox(height: 12),
          Text(
            'Se usará tu ubicación GPS para verificar que los estudiantes estén cerca. '
            'Los estudiantes recibirán el código por Bluetooth.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMd.copyWith(height: 1.65),
          ),

          if (error != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.errorSurface,
                borderRadius: AppRadius.mdBr,
              ),
              child: Text(
                error!,
                style: AppTextStyles.bodySm.copyWith(color: AppColors.error),
                textAlign: TextAlign.center,
              ),
            ),
          ],

          const SizedBox(height: 44),

          AppPrimaryButton(
            label: 'Iniciar llamado a lista',
            icon: Icons.play_arrow_rounded,
            onPressed: () =>
                ref.read(openSessionProvider.notifier).open(groupId),
          ),
        ],
      ),
    );
  }
}

// ── Loading View ───────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: 20),
          Text(
            'Obteniendo ubicación e iniciando sesión...',
            style: AppTextStyles.bodyMd,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Active View ────────────────────────────────────────────────────

class _ActiveView extends ConsumerWidget {
  final String code, groupId, sessionId;
  const _ActiveView({
    required this.code,
    required this.groupId,
    required this.sessionId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendances = ref.watch(attendanceProvider(sessionId));

    return Column(
      children: [
        // ── Session active banner ─────────────────────────────
        Container(
          margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryLight],
            ),
            borderRadius: AppRadius.xlBr,
            boxShadow: AppShadows.elevated,
          ),
          child: Row(
            children: [
              const _BluetoothPulse(),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sesión activa',
                    style: AppTextStyles.h2.copyWith(color: Colors.white),
                  ),
                  Text(
                    'Emitiendo código por Bluetooth',
                    style: AppTextStyles.bodySm.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // ── Attendance list ───────────────────────────────────
        Expanded(
          child: attendances.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (records) => _AttendanceList(records: records),
          ),
        ),

        // ── Stop button ───────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: AppOutlinedButton(
            label: 'Detener llamado a lista',
            icon: Icons.stop_circle_outlined,
            color: AppColors.error,
            onPressed: () async {
              await ref.read(openSessionProvider.notifier).close();
              if (context.mounted) Navigator.of(context).pop();
            },
          ),
        ),
      ],
    );
  }
}

class _BluetoothPulse extends StatefulWidget {
  const _BluetoothPulse();
  @override
  State<_BluetoothPulse> createState() => _BluetoothPulseState();
}

class _BluetoothPulseState extends State<_BluetoothPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _anim = Tween(
      begin: 0.85,
      end: 1.15,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _anim,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: AppRadius.smBr,
        ),
        child: const Icon(
          Icons.bluetooth_searching_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}

// ── Attendance list ────────────────────────────────────────────────

class _AttendanceList extends StatelessWidget {
  final List<AttendanceRecord> records;
  const _AttendanceList({required this.records});

  @override
  Widget build(BuildContext context) {
    final present = records
        .where((r) => r.status != AttendanceStatus.absent)
        .toList();
    final absent = records
        .where((r) => r.status == AttendanceStatus.absent)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Row(
            children: [
              Text('Presentes', style: AppTextStyles.h2),
              const SizedBox(width: 8),
              StatusBadge.present(label: '${present.length}/${records.length}'),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              ...present.map((r) => _AttendanceTile(record: r)),
              if (absent.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      Text('Sin marcar', style: AppTextStyles.h2),
                      const SizedBox(width: 8),
                      StatusBadge.absent(label: '${absent.length}'),
                    ],
                  ),
                ),
                ...absent.map((r) => _AttendanceTile(record: r)),
              ],
              const SizedBox(height: 12),
            ],
          ),
        ),
      ],
    );
  }
}

class _AttendanceTile extends StatelessWidget {
  final AttendanceRecord record;
  const _AttendanceTile({required this.record});

  @override
  Widget build(BuildContext context) {
    final isPresent = record.status != AttendanceStatus.absent;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isPresent
                    ? AppColors.presentSurface
                    : AppColors.absentSurface,
                borderRadius: AppRadius.smBr,
              ),
              child: Icon(
                isPresent
                    ? Icons.check_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: isPresent ? AppColors.present : AppColors.absent,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(record.studentName, style: AppTextStyles.labelLg),
                  if (record.checkInTime != null)
                    Text(
                      'Marcó a las ${TimeOfDay.fromDateTime(record.checkInTime!).format(context)}',
                      style: AppTextStyles.bodySm,
                    )
                  else
                    Text('Sin marcar', style: AppTextStyles.bodySm),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
