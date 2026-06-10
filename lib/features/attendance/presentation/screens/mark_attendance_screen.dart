import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoasistencia/core/theme/app_theme.dart';
import 'package:geoasistencia/features/attendance/presentation/providers/mark_attendance_provider.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart' as ll;

class MarkAttendanceScreen extends ConsumerWidget {
  final String groupId;
  const MarkAttendanceScreen({super.key, required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(markAttendanceProvider(groupId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Registrar asistencia'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: state.when(
        data: (result) => result == null
            ? _ScanView(groupId: groupId)
            : _SuccessView(result: result),
        loading: () => const _LoadingView(),
        error: (e, _) => _ErrorView(message: e.toString(), groupId: groupId),
      ),
    );
  }
}

class _ScanView extends ConsumerWidget {
  final String groupId;
  const _ScanView({required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GreenGradientBackground(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated icon container
              _PulsingIcon(),

              const SizedBox(height: 36),

              Text('Registrar asistencia', style: AppTextStyles.displaySm),
              const SizedBox(height: 12),
              Text(
                'Asegúrate de estar cerca del docente y tener '
                'Bluetooth activado. Se verificará tu ubicación GPS.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMd.copyWith(height: 1.65),
              ),

              const SizedBox(height: 12),

              // ── Requirements chips ──────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  InfoChip(icon: Icons.bluetooth_rounded, label: 'Bluetooth'),
                  SizedBox(width: 10),
                  InfoChip(icon: Icons.location_on_rounded, label: 'GPS'),
                ],
              ),

              const SizedBox(height: 44),

              AppPrimaryButton(
                label: 'Registrar mi asistencia',
                icon: Icons.check_circle_outline_rounded,
                onPressed: () =>
                    ref.read(markAttendanceProvider(groupId).notifier).mark(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PulsingIcon extends StatefulWidget {
  @override
  State<_PulsingIcon> createState() => _PulsingIconState();
}

class _PulsingIconState extends State<_PulsingIcon>
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
      begin: 1.0,
      end: 1.1,
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
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.bluetooth_searching_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return GreenGradientBackground(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 20),
            Text(
              'Buscando sesión BLE y verificando ubicación...',
              style: AppTextStyles.bodyMd,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  final AttendanceResult result;
  const _SuccessView({required this.result});

  @override
  Widget build(BuildContext context) {
    final pos = ll.LatLng(result.latitude, result.longitude);

    final hour = DateFormat('hh:mm a').format(result.markedAt);
    final day = DateFormat('dd').format(result.markedAt);
    final month = DateFormat('MMMM', 'es').format(result.markedAt);

    return Column(
      children: [
        SizedBox(
          height: 240,
          child: FlutterMap(
            options: MapOptions(
              initialCenter: pos,
              initialZoom: 17,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.none, // mapa bloqueado como antes
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: 'com.geoasistencia.app',
              ),

              MarkerLayer(
                markers: [
                  Marker(
                    point: pos,
                    width: 50,
                    height: 50,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.successSurface,
                    borderRadius: AppRadius.mdBr,
                    border: Border.all(
                      color: AppColors.success.withOpacity(0.3),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.present,
                        size: 22,
                      ),
                      SizedBox(width: 10),
                      Text('Asistencia registrada exitosamente'),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Text('Ubicación registrada', style: AppTextStyles.h2),
                const SizedBox(height: 4),
                Text(
                  result.address ?? 'Ubicación registrada correctamente',
                  style: AppTextStyles.bodyMd,
                ),

                const SizedBox(height: 20),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    InfoChip(icon: Icons.access_time_rounded, label: hour),
                    InfoChip(icon: Icons.calendar_today_rounded, label: day),
                    InfoChip(icon: Icons.event_rounded, label: month),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorView extends ConsumerWidget {
  final String message;
  final String groupId;
  const _ErrorView({required this.message, required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GreenGradientBackground(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.errorSurface,
                borderRadius: AppRadius.xlBr,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 24),
            Text('No se pudo registrar', style: AppTextStyles.h1),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.error),
            ),
            const SizedBox(height: 36),
            AppPrimaryButton(
              label: 'Reintentar',
              icon: Icons.refresh_rounded,
              onPressed: () =>
                  ref.read(markAttendanceProvider(groupId).notifier).mark(),
            ),
          ],
        ),
      ),
    );
  }
}
