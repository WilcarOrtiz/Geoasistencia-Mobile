import 'package:flutter/material.dart';
import 'package:geoasistencia/core/services/permission_service.dart';
import 'package:geoasistencia/core/constants/app_routes.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionGateScreen extends StatefulWidget {
  final String nextRoute;
  const PermissionGateScreen({super.key, required this.nextRoute});

  @override
  State<PermissionGateScreen> createState() => _PermissionGateScreenState();
}

class _PermissionGateScreenState extends State<PermissionGateScreen>
    with WidgetsBindingObserver {
  _ScreenState _state = _ScreenState.checking;
  bool _permanentlyDenied = false;
  bool _btOff = false;
  bool _gpsOff = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _run();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Cuando el usuario vuelve de Ajustes, re-verificamos
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _run();
    }
  }

  Future<void> _run() async {
    if (!mounted) return;
    setState(() => _state = _ScreenState.checking);

    // Si ya están todos concedidos, saltamos directo a verificar servicios
    final yaOk = await PermissionService.allGranted();
    if (!mounted) return;

    if (!yaOk) {
      // Pedir los que faltan
      final result = await PermissionService.requestAllPermissions();
      if (!mounted) return;

      if (result == PermissionResult.permanentlyDenied) {
        setState(() {
          _state = _ScreenState.permissionDenied;
          _permanentlyDenied = true;
        });
        return;
      }

      if (result == PermissionResult.denied) {
        setState(() {
          _state = _ScreenState.permissionDenied;
          _permanentlyDenied = false;
        });
        return;
      }
    }

    // Permisos OK → verificar servicios encendidos
    final services = await PermissionService.servicesStatus();
    if (!mounted) return;

    final btOff = !(services['bluetooth'] ?? false);
    final gpsOff = !(services['gps'] ?? false);

    if (btOff || gpsOff) {
      setState(() {
        _state = _ScreenState.servicesOff;
        _btOff = btOff;
        _gpsOff = gpsOff;
      });
      return;
    }

    Navigator.pushReplacementNamed(context, widget.nextRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: switch (_state) {
          _ScreenState.checking => _buildChecking(),
          _ScreenState.permissionDenied => _buildPermissionDenied(),
          _ScreenState.servicesOff => _buildServicesOff(),
        },
      ),
    );
  }

  Widget _buildChecking() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text('Verificando permisos…'),
        ],
      ),
    );
  }

  Widget _buildPermissionDenied() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_outline, size: 72, color: Colors.orange),
          const SizedBox(height: 24),
          const Text(
            'Permisos necesarios',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            _permanentlyDenied
                ? 'Bloqueaste algunos permisos. Ve a Ajustes → GeoAsistencia y activa Bluetooth y Ubicación manualmente.'
                : 'GeoAsistencia necesita:\n\n• Bluetooth\n• Ubicación\n\nSon necesarios para registrar asistencia.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, height: 1.5),
          ),
          const SizedBox(height: 32),
          if (_permanentlyDenied)
            FilledButton.icon(
              onPressed: () async {
                await openAppSettings();
                // Al volver, didChangeAppLifecycleState llama _run() solo
              },
              icon: const Icon(Icons.settings_outlined),
              label: const Text('Ir a Ajustes'),
            )
          else
            FilledButton.icon(
              onPressed: _run,
              icon: const Icon(Icons.refresh),
              label: const Text('Conceder permisos'),
            ),
        ],
      ),
    );
  }

  Widget _buildServicesOff() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            size: 72,
            color: Colors.amber,
          ),
          const SizedBox(height: 24),
          const Text(
            'Activa los servicios',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (_btOff)
            _ServiceTile(
              icon: Icons.bluetooth_disabled,
              color: Colors.blue,
              label: 'Bluetooth está apagado',
              hint: 'Actívalo desde el Centro de control o en Ajustes.',
            ),
          if (_gpsOff)
            _ServiceTile(
              icon: Icons.location_off,
              color: Colors.green,
              label: 'Ubicación está apagada',
              hint: 'Actívala en Ajustes → Privacidad → Localización.',
            ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: _run,
            icon: const Icon(Icons.refresh),
            label: const Text('Ya los activé, continuar'),
          ),
        ],
      ),
    );
  }
}

enum _ScreenState { checking, permissionDenied, servicesOff }

class _ServiceTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String hint;

  const _ServiceTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  hint,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
