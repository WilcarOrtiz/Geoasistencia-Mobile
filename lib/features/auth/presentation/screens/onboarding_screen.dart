import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geoasistencia/core/constants/app_routes.dart';
import 'package:geoasistencia/core/services/permission_service.dart';
import 'package:geoasistencia/core/utils/storage.dart';
import 'package:permission_handler/permission_handler.dart';

// ─────────────────────────────────────────────────────────────────────────────
// OnboardingScreen
//
// Flujo de páginas:
//   0 · Bienvenida
//   1 · Para qué sirve el Bluetooth  → botón pide permiso BT
//   2 · Para qué sirve la Ubicación  → botón pide permiso GPS
//   3 · Todo listo → ir a Login
//
// Los permisos se piden UNA SOLA VEZ aquí.
// Los días siguientes el Splash detecta allGranted() == true y no pasa por aquí.
// ─────────────────────────────────────────────────────────────────────────────

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  // Estado de permisos (para actualizar el botón en tiempo real)
  bool _btGranted = false;
  bool _locGranted = false;
  bool _btRequesting = false;
  bool _locRequesting = false;

  @override
  void initState() {
    super.initState();
    _refreshPermStatus();
  }

  Future<void> _refreshPermStatus() async {
    final bt = await PermissionService.bluetoothGranted();
    final loc = await PermissionService.locationGranted();
    if (mounted)
      setState(() {
        _btGranted = bt;
        _locGranted = loc;
      });
  }

  // ── Navegación ────────────────────────────────────────────────────────────

  void _next() {
    if (_page < 3) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  void _finish() {
    StorageService.saveData('onboarding', 'true');
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  // ── Solicitud de permisos ─────────────────────────────────────────────────

  Future<void> _requestBt() async {
    setState(() => _btRequesting = true);
    final r = await PermissionService.requestBluetooth();
    if (!mounted) return;
    if (r == PermStatus.permanentlyDenied) await openAppSettings();
    await _refreshPermStatus();
    setState(() => _btRequesting = false);
    if (_btGranted) _next();
  }

  Future<void> _requestLoc() async {
    setState(() => _locRequesting = true);
    // Pequeña pausa en iOS para asegurarnos de que el sistema está listo
    if (Platform.isIOS) await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    final r = await PermissionService.requestLocation();
    if (!mounted) return;
    if (r == PermStatus.permanentlyDenied) await openAppSettings();
    await _refreshPermStatus();
    setState(() => _locRequesting = false);
    if (_locGranted) _next();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Botón saltar (solo en páginas 0-1, no en las de permisos)
            Align(
              alignment: Alignment.topRight,
              child: AnimatedOpacity(
                opacity: _page < 2 ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                child: TextButton(
                  onPressed: _page < 2 ? _finish : null,
                  child: const Text('Saltar'),
                ),
              ),
            ),

            // Páginas
            Expanded(
              child: PageView(
                controller: _controller,
                physics:
                    const NeverScrollableScrollPhysics(), // solo con botones
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  _PageWelcome(onNext: _next),
                  _PageBluetooth(
                    granted: _btGranted,
                    requesting: _btRequesting,
                    onRequest: _requestBt,
                    onSkip: _next,
                  ),
                  _PageLocation(
                    granted: _locGranted,
                    requesting: _locRequesting,
                    onRequest: _requestLoc,
                    onSkip: _next,
                  ),
                  _PageReady(onFinish: _finish),
                ],
              ),
            ),

            // Indicadores de página
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (i) => _Dot(active: _page == i)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Páginas individuales ──────────────────────────────────────────────────────

class _PageWelcome extends StatelessWidget {
  final VoidCallback onNext;
  const _PageWelcome({required this.onNext});

  @override
  Widget build(BuildContext context) {
    return _PageShell(
      icon: Icons.school,
      iconColor: Colors.indigo,
      title: 'Bienvenido a\nGeoAsistencia',
      description:
          'La app que hace el registro de asistencia más fácil, rápido '
          'y seguro para docentes y estudiantes.',
      button: _PrimaryButton(label: 'Comenzar', onPressed: onNext),
    );
  }
}

class _PageBluetooth extends StatelessWidget {
  final bool granted;
  final bool requesting;
  final VoidCallback onRequest;
  final VoidCallback onSkip;

  const _PageBluetooth({
    required this.granted,
    required this.requesting,
    required this.onRequest,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return _PageShell(
      icon: Icons.bluetooth,
      iconColor: Colors.blue,
      title: 'Bluetooth',
      description:
          'GeoAsistencia usa Bluetooth para verificar que estás '
          'físicamente cerca del docente en el momento del llamado a lista.\n\n'
          'Sin este permiso no podrás registrar ni tomar asistencia.',
      button: granted
          ? _GrantedButton()
          : _PrimaryButton(
              label: requesting ? 'Solicitando…' : 'Permitir Bluetooth',
              onPressed: requesting ? null : onRequest,
              icon: Icons.bluetooth,
              color: Colors.blue,
            ),
      secondaryButton: granted
          ? _PrimaryButton(label: 'Continuar', onPressed: onSkip)
          : _TextButton(label: 'Ahora no', onPressed: onSkip),
    );
  }
}

class _PageLocation extends StatelessWidget {
  final bool granted;
  final bool requesting;
  final VoidCallback onRequest;
  final VoidCallback onSkip;

  const _PageLocation({
    required this.granted,
    required this.requesting,
    required this.onRequest,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return _PageShell(
      icon: Icons.location_on,
      iconColor: Colors.green,
      title: 'Ubicación',
      description:
          'La ubicación se usa para confirmar que estás dentro del '
          'aula al momento de registrar la asistencia.\n\n'
          'Tu ubicación nunca se comparte fuera de la app ni se almacena '
          'cuando no estás en clase.',
      button: granted
          ? _GrantedButton()
          : _PrimaryButton(
              label: requesting ? 'Solicitando…' : 'Permitir Ubicación',
              onPressed: requesting ? null : onRequest,
              icon: Icons.location_on,
              color: Colors.green,
            ),
      secondaryButton: granted
          ? _PrimaryButton(label: 'Continuar', onPressed: onSkip)
          : _TextButton(label: 'Ahora no', onPressed: onSkip),
    );
  }
}

class _PageReady extends StatelessWidget {
  final VoidCallback onFinish;
  const _PageReady({required this.onFinish});

  @override
  Widget build(BuildContext context) {
    return _PageShell(
      icon: Icons.check_circle,
      iconColor: Colors.teal,
      title: '¡Todo listo!',
      description:
          'Ya puedes iniciar sesión y comenzar a usar GeoAsistencia.\n\n'
          'Recuerda tener Bluetooth y GPS activos cada vez que registres asistencia.',
      button: _PrimaryButton(
        label: 'Ir al inicio de sesión',
        onPressed: onFinish,
      ),
    );
  }
}

// ── Componentes UI ────────────────────────────────────────────────────────────

class _PageShell extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final Widget button;
  final Widget? secondaryButton;

  const _PageShell({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.button,
    this.secondaryButton,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 72, color: iconColor),
          ),
          const SizedBox(height: 36),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              height: 1.65,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(width: double.infinity, child: button),
          if (secondaryButton != null) ...[
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, child: secondaryButton!),
          ],
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;

  const _PrimaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final child = icon != null
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Text(label),
            ],
          )
        : Text(label);

    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: color ?? Theme.of(context).colorScheme.primary,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: child,
    );
  }
}

class _GrantedButton extends StatelessWidget {
  const _GrantedButton();

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: null, // deshabilitado visualmente
      icon: const Icon(Icons.check_circle),
      label: const Text('Permiso concedido'),
      style: FilledButton.styleFrom(
        backgroundColor: Colors.green,
        disabledBackgroundColor: Colors.green.withOpacity(0.8),
        disabledForegroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }
}

class _TextButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const _TextButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(label, style: const TextStyle(color: Colors.black45)),
    );
  }
}

class _Dot extends StatelessWidget {
  final bool active;
  const _Dot({required this.active});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: active ? 20 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: active
            ? Theme.of(context).colorScheme.primary
            : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
