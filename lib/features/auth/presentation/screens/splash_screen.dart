import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoasistencia/core/services/permission_service.dart';
import 'package:geoasistencia/core/utils/storage.dart';
import 'package:geoasistencia/core/theme/app_theme.dart';
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
    await Future.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;

    final session = Supabase.instance.client.auth.currentSession;
    final vioOnboarding = StorageService.getData('onboarding') == 'true';
    final permsOk = await PermissionService.allGranted();
    if (!mounted) return;

    if (!vioOnboarding) {
      Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
      return;
    }

    if (permsOk) {
      final destino = session != null ? AppRoutes.home : AppRoutes.login;
      Navigator.pushReplacementNamed(context, destino);
      return;
    }

    final destino = session != null ? AppRoutes.home : AppRoutes.login;
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.permissions,
      arguments: destino,
    );
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
                    // ── Logo container ────────────────────────
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
