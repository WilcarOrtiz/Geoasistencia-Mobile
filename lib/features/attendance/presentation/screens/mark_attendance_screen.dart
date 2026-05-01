// features/attendance/presentation/screens/mark_attendance_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geoasistencia/features/attendance/presentation/providers/mark_attendance_provider.dart';
import 'package:intl/intl.dart';

class MarkAttendanceScreen extends ConsumerWidget {
  final String groupId;
  const MarkAttendanceScreen({super.key, required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(markAttendanceProvider(groupId));

    return Scaffold(
      appBar: AppBar(title: const Text('Registrar asistencia')),
      body: state.when(
        data: (result) => result == null
            ? _ScanView(groupId: groupId)
            : _SuccessView(result: result),
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Buscando sesión BLE y verificando ubicación...'),
            ],
          ),
        ),
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
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.bluetooth_searching, size: 80, color: Colors.blue),
          const SizedBox(height: 24),
          const Text(
            'Asegúrate de estar cerca del docente y tener Bluetooth activado.\nSe verificará tu ubicación GPS.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Registrar mi asistencia'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () =>
                  ref.read(markAttendanceProvider(groupId).notifier).mark(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  final AttendanceResult result;
  const _SuccessView({required this.result});

  @override
  Widget build(BuildContext context) {
    final pos = LatLng(result.latitude, result.longitude);
    final timeStr = DateFormat('dd/MM/yyyy HH:mm').format(result.markedAt);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          color: Colors.green.shade50,
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Asistencia registrada',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(timeStr, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: GoogleMap(
            initialCameraPosition: CameraPosition(target: pos, zoom: 17),
            markers: {
              Marker(
                markerId: const MarkerId('student'),
                position: pos,
                infoWindow: InfoWindow(title: 'Tu ubicación', snippet: timeStr),
              ),
            },
            myLocationEnabled: true,
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
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () =>
                ref.read(markAttendanceProvider(groupId).notifier).mark(),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}
