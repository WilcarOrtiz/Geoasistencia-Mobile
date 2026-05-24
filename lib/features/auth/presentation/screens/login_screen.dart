import 'package:flutter/material.dart';
import 'package:geoasistencia/core/theme/app_theme.dart';
import 'package:geoasistencia/features/auth/presentation/widgets/login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: GreenGradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),

                // ── Brand mark ────────────────────────────────
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: AppRadius.lgBr,
                      boxShadow: AppShadows.elevated,
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      size: 38,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // ── Heading ───────────────────────────────────
                Text('Iniciar sesión', style: AppTextStyles.displaySm),
                const SizedBox(height: 6),
                Text(
                  'Ingresa con tu cuenta institucional',
                  style: AppTextStyles.bodyMd,
                ),

                const SizedBox(height: 36),

                // ── Form card ─────────────────────────────────
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppRadius.xlBr,
                    border: Border.all(color: AppColors.borderSubtle),
                    boxShadow: AppShadows.card,
                  ),
                  padding: const EdgeInsets.all(24),
                  child: const LoginForm(),
                ),

                const SizedBox(height: 28),

                // ── Footer ────────────────────────────────────
                Center(
                  child: Text(
                    '© GeoAsistencia · UPC',
                    style: AppTextStyles.bodySm,
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
