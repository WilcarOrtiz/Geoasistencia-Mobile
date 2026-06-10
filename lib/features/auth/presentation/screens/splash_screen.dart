import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoasistencia/core/services/permission_service.dart';
import 'package:geoasistencia/core/utils/storage.dart';
import 'package:geoasistencia/core/theme/app_theme.dart';
import 'package:geoasistencia/features/auth/presentation/providers/auth_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geoasistencia/core/constants/app_routes.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _scaleAnim = Tween(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));

    _ctrl.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;

    final vioOnboarding = StorageService.getData('onboarding') == 'true';

    if (!vioOnboarding) {
      Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
      return;
    }

    final session = Supabase.instance.client.auth.currentSession;

    if (session == null) {
      _navigateAfterPermissions(AppRoutes.login);
      return;
    }

    // Esperar que _restoreSession() termine (máx 5s)
    for (int i = 0; i < 50; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;

      final s = ref.read(authProvider);

      if (s.asData?.value != null) {
        _navigateAfterPermissions(AppRoutes.home);
        return;
      }
      if (s.hasError) {
        _navigateAfterPermissions(AppRoutes.login);
        return;
      }
      if (s.asData != null && s.asData!.value == null) {
        // Restauración terminó pero no hay usuario válido
        _navigateAfterPermissions(AppRoutes.login);
        return;
      }
    }

    // Timeout → login
    _navigateAfterPermissions(AppRoutes.login);
  }

  Future<void> _navigateAfterPermissions(String destination) async {
    if (!mounted) return;

    final permsOk = await PermissionService.allGranted();
    if (!mounted) return;

    if (permsOk) {
      Navigator.pushReplacementNamed(context, destination);
    } else {
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.permissions,
        arguments: destination,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: GreenGradientBackground(
        child: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: ScaleTransition(
                scale: _scaleAnim,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: AppRadius.xlBr,
                        boxShadow: AppShadows.elevated,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.school_rounded,
                          size: 52,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'GeoAsistencia',
                      style: AppTextStyles.displayMd.copyWith(
                        color: AppColors.primary,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Registro inteligente de asistencia',
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 56),
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.primaryMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
