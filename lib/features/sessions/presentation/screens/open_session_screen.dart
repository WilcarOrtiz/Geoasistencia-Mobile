// features/sessions/presentation/screens/open_session_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoasistencia/features/sessions/presentation/providers/open_session_provider.dart';

class OpenSessionScreen extends ConsumerWidget {
  final String groupId;
  const OpenSessionScreen({super.key, required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(openSessionProvider);

    return PopScope(
      onPopInvokedWithResult: (_, __) =>
          ref.read(openSessionProvider.notifier).close(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Llamado a lista')),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: switch (state.status) {
            OpenSessionStatus.idle || OpenSessionStatus.error => _IdleView(
              groupId: groupId,
              error: state.error,
            ),
            OpenSessionStatus.loading => const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Obteniendo ubicación e iniciando sesión...'),
                ],
              ),
            ),
            OpenSessionStatus.active => _ActiveView(code: state.code!),
          },
        ),
      ),
    );
  }
}

class _IdleView extends ConsumerWidget {
  final String groupId;
  final String? error;
  const _IdleView({required this.groupId, this.error});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.sensors, size: 80, color: Colors.blue),
        const SizedBox(height: 24),
        const Text(
          'Se usará tu ubicación GPS para verificar que los estudiantes estén cerca.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
        if (error != null) ...[
          const SizedBox(height: 16),
          Text(
            error!,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.play_arrow),
            label: const Text('Iniciar llamado a lista'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: () =>
                ref.read(openSessionProvider.notifier).open(groupId),
          ),
        ),
      ],
    );
  }
}

class _ActiveView extends StatelessWidget {
  final String code;
  const _ActiveView({required this.code});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.bluetooth_searching, size: 80, color: Colors.green),
        const SizedBox(height: 16),
        const Text(
          'Sesión activa',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Emitiendo código por Bluetooth.\nLos estudiantes ya pueden registrar su asistencia.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 32),
        // Ícono animado de BLE emitiendo
        const _BluetoothPulse(),
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
    _anim = Tween(begin: 0.8, end: 1.2).animate(_ctrl);
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
      child: const Icon(Icons.bluetooth, size: 60, color: Colors.blue),
    );
  }
}
