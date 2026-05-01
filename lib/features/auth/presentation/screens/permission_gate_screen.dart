import 'package:flutter/material.dart';
import 'package:geoasistencia/core/services/permission_service.dart';
import 'package:geoasistencia/core/constants/app_routes.dart';
import 'package:permission_handler/permission_handler.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PermissionGateScreen
//
// Solo se muestra en casos excepcionales:
//   · El usuario revocó un permiso desde Ajustes del sistema
//   · Dispositivo muy restrictivo
//
// En el flujo normal (uso diario) el Splash detecta allGranted() == true
// y nunca llega aquí.
// ─────────────────────────────────────────────────────────────────────────────

class PermissionGateScreen extends StatefulWidget {
  final String nextRoute;
  const PermissionGateScreen({super.key, required this.nextRoute});

  @override
  State<PermissionGateScreen> createState() => _PermissionGateScreenState();
}

class _PermissionGateScreenState extends State<PermissionGateScreen>
    with WidgetsBindingObserver {
  _State _s = _State.checking;
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

  // Cuando vuelve de Ajustes del sistema
  @override
  void didChangeAppLifecycleState(AppLifecycleState s) {
    if (s == AppLifecycleState.resumed) _run();
  }

  Future<void> _run() async {
    if (!mounted) return;
    setState(() => _s = _State.checking);

    final ok = await PermissionService.allGranted();
    if (!mounted) return;

    if (!ok) {
      setState(() => _s = _State.permsDenied);
      return;
    }

    // Verificar servicios encendidos
    final sv = await PermissionService.servicesStatus();
    if (!mounted) return;

    if (!sv.bt || !sv.gps) {
      setState(() {
        _s = _State.servicesOff;
        _btOff = !sv.bt;
        _gpsOff = !sv.gps;
      });
      return;
    }

    Navigator.pushReplacementNamed(context, widget.nextRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: switch (_s) {
          _State.checking => const _Loading(),
          _State.permsDenied => _PermsDenied(onOpenSettings: openAppSettings),
          _State.servicesOff => _ServicesOff(
            btOff: _btOff,
            gpsOff: _gpsOff,
            onRetry: _run,
          ),
        },
      ),
    );
  }
}

enum _State { checking, permsDenied, servicesOff }

// ── Widgets internos ──────────────────────────────────────────────────────────

class _Loading extends StatelessWidget {
  const _Loading();
  @override
  Widget build(BuildContext context) => const Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 16),
        Text('Verificando…'),
      ],
    ),
  );
}

class _PermsDenied extends StatelessWidget {
  final Future<void> Function() onOpenSettings;
  const _PermsDenied({required this.onOpenSettings});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(36),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_outline, size: 72, color: Colors.orange),
          const SizedBox(height: 24),
          const Text(
            'Permisos requeridos',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Parece que revocaste el acceso a Bluetooth o Ubicación.\n\n'
            'Ve a Ajustes → GeoAsistencia y actívalos para continuar.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, height: 1.6, color: Colors.black54),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onOpenSettings,
              icon: const Icon(Icons.settings_outlined),
              label: const Text('Abrir Ajustes'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServicesOff extends StatelessWidget {
  final bool btOff;
  final bool gpsOff;
  final VoidCallback onRetry;

  const _ServicesOff({
    required this.btOff,
    required this.gpsOff,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(36),
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
          const SizedBox(height: 8),
          const Text(
            'Para registrar asistencia necesitas tener activos:',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 20),
          if (btOff)
            _Tile(
              icon: Icons.bluetooth_disabled,
              color: Colors.blue,
              label: 'Bluetooth apagado',
              hint: 'Actívalo desde el Centro de control.',
            ),
          if (gpsOff)
            _Tile(
              icon: Icons.location_off,
              color: Colors.green,
              label: 'GPS / Ubicación apagada',
              hint: 'Actívala en Ajustes → Privacidad → Localización.',
            ),
          const SizedBox(height: 36),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Ya los activé, continuar'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String hint;
  const _Tile({
    required this.icon,
    required this.color,
    required this.label,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  hint,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
