import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geoasistencia/core/constants/app_routes.dart';
import 'package:geoasistencia/core/services/permission_service.dart';
import 'package:geoasistencia/core/utils/storage.dart';
import 'package:geoasistencia/core/theme/app_theme.dart';
import 'package:permission_handler/permission_handler.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

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

  void _next() {
    if (_page < 3) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
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
    if (Platform.isIOS) await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    final r = await PermissionService.requestLocation();
    if (!mounted) return;
    if (r == PermStatus.permanentlyDenied) await openAppSettings();
    await _refreshPermStatus();
    setState(() => _locRequesting = false);
    if (_locGranted) _next();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: GreenGradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // ── Skip button ─────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AnimatedOpacity(
                      opacity: _page < 2 ? 1 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: TextButton(
                        onPressed: _page < 2 ? _finish : null,
                        child: Text(
                          'Saltar',
                          style: AppTextStyles.labelMd.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Pages ────────────────────────────────────────
              Expanded(
                child: PageView(
                  controller: _controller,
                  physics: const NeverScrollableScrollPhysics(),
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

              // ── Dots ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (i) => _Dot(active: _page == i)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Pages ─────────────────────────────────────────────────────────

class _PageWelcome extends StatelessWidget {
  final VoidCallback onNext;
  const _PageWelcome({required this.onNext});

  @override
  Widget build(BuildContext context) {
    return _PageShell(
      icon: Icons.school_rounded,
      iconBg: AppColors.primarySurface,
      iconColor: AppColors.primary,
      title: 'Bienvenido a\nGeoAsistencia',
      description:
          'La app que hace el registro de asistencia más fácil, rápido '
          'y seguro para docentes y estudiantes.',
      button: AppPrimaryButton(label: 'Comenzar', onPressed: onNext),
    );
  }
}

class _PageBluetooth extends StatelessWidget {
  final bool granted, requesting;
  final VoidCallback onRequest, onSkip;

  const _PageBluetooth({
    required this.granted,
    required this.requesting,
    required this.onRequest,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return _PageShell(
      icon: Icons.bluetooth_rounded,
      iconBg: const Color(0xFFEEF4FF),
      iconColor: const Color(0xFF3B82F6),
      title: 'Bluetooth',
      description:
          'GeoAsistencia usa Bluetooth para verificar que estás '
          'físicamente cerca del docente en el momento del llamado a lista.\n\n'
          'Sin este permiso no podrás registrar ni tomar asistencia.',
      button: granted
          ? _GrantedButton()
          : AppPrimaryButton(
              label: requesting ? 'Solicitando…' : 'Permitir Bluetooth',
              onPressed: requesting ? null : onRequest,
              icon: Icons.bluetooth_rounded,
              isLoading: requesting,
            ),
      secondaryButton: granted
          ? AppPrimaryButton(label: 'Continuar', onPressed: onSkip)
          : TextButton(
              onPressed: onSkip,
              child: Text(
                'Ahora no',
                style: AppTextStyles.labelMd.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ),
    );
  }
}

class _PageLocation extends StatelessWidget {
  final bool granted, requesting;
  final VoidCallback onRequest, onSkip;

  const _PageLocation({
    required this.granted,
    required this.requesting,
    required this.onRequest,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return _PageShell(
      icon: Icons.location_on_rounded,
      iconBg: AppColors.primarySurface,
      iconColor: AppColors.primary,
      title: 'Ubicación',
      description:
          'La ubicación se usa para confirmar que estás dentro del '
          'aula al momento de registrar la asistencia.\n\n'
          'Tu ubicación nunca se comparte fuera de la app ni se almacena '
          'cuando no estás en clase.',
      button: granted
          ? _GrantedButton()
          : AppPrimaryButton(
              label: requesting ? 'Solicitando…' : 'Permitir Ubicación',
              onPressed: requesting ? null : onRequest,
              icon: Icons.location_on_rounded,
              isLoading: requesting,
            ),
      secondaryButton: granted
          ? AppPrimaryButton(label: 'Continuar', onPressed: onSkip)
          : TextButton(
              onPressed: onSkip,
              child: Text(
                'Ahora no',
                style: AppTextStyles.labelMd.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ),
    );
  }
}

class _PageReady extends StatelessWidget {
  final VoidCallback onFinish;
  const _PageReady({required this.onFinish});

  @override
  Widget build(BuildContext context) {
    return _PageShell(
      icon: Icons.check_circle_rounded,
      iconBg: AppColors.successSurface,
      iconColor: AppColors.success,
      title: '¡Todo listo!',
      description:
          'Ya puedes iniciar sesión y comenzar a usar GeoAsistencia.\n\n'
          'Recuerda tener Bluetooth y GPS activos cada vez que registres asistencia.',
      button: AppPrimaryButton(
        label: 'Ir al inicio de sesión',
        onPressed: onFinish,
      ),
    );
  }
}

// ── Shell ──────────────────────────────────────────────────────────

class _PageShell extends StatelessWidget {
  final IconData icon;
  final Color iconBg, iconColor;
  final String title, description;
  final Widget button;
  final Widget? secondaryButton;

  const _PageShell({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.button,
    this.secondaryButton,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon bubble
          Container(
            width: 104,
            height: 104,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: AppRadius.xlBr,
              border: Border.all(
                color: iconColor.withOpacity(0.18),
                width: 1.5,
              ),
            ),
            child: Icon(icon, size: 52, color: iconColor),
          ),

          const SizedBox(height: 36),

          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.displaySm,
          ),

          const SizedBox(height: 14),

          Text(
            description,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMd.copyWith(height: 1.65),
          ),

          const SizedBox(height: 44),

          button,

          if (secondaryButton != null) ...[
            const SizedBox(height: 10),
            SizedBox(width: double.infinity, child: secondaryButton!),
          ],
        ],
      ),
    );
  }
}

// ── Componentes pequeños ───────────────────────────────────────────

class _GrantedButton extends StatelessWidget {
  const _GrantedButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton.icon(
        onPressed: null,
        icon: const Icon(Icons.check_circle_rounded),
        label: const Text('Permiso concedido'),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.success,
          disabledBackgroundColor: AppColors.success.withOpacity(0.85),
          disabledForegroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.mdBr),
        ),
      ),
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
      curve: Curves.easeOut,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: active ? 24 : 7,
      height: 7,
      decoration: BoxDecoration(
        color: active ? AppColors.primary : AppColors.borderSubtle,
        borderRadius: AppRadius.fullBr,
      ),
    );
  }
}
