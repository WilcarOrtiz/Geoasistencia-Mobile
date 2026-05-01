import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoasistencia/core/services/permission_service.dart';
import 'package:geoasistencia/core/utils/storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geoasistencia/core/constants/app_routes.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _init(context);
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }

  Future<void> _init(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 1));
    if (!context.mounted) return;

    final session = Supabase.instance.client.auth.currentSession;
    final vioOnboarding = StorageService.getData('onboarding') == 'true';
    final permsOk = await PermissionService.allGranted();
    if (!context.mounted) return;

    // ── Casos posibles ────────────────────────────────────────────────────
    //
    // 1. Primera vez (nunca vio onboarding):
    //    → Onboarding (que pide permisos al final y luego va a Login)
    //
    // 2. Ya vio onboarding, permisos OK, sesión activa:
    //    → Home  (flujo diario normal, sin interrupciones)
    //
    // 3. Ya vio onboarding, permisos OK, sin sesión:
    //    → Login
    //
    // 4. Ya vio onboarding pero permisos faltan (ej: usuario los revocó):
    //    → PermissionGate → Login o Home según sesión
    //
    if (!vioOnboarding) {
      Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
      return;
    }

    if (permsOk) {
      final destino = session != null ? AppRoutes.home : AppRoutes.login;
      Navigator.pushReplacementNamed(context, destino);
      return;
    }

    // Permisos revocados después de haber visto el onboarding
    final destino = session != null ? AppRoutes.home : AppRoutes.login;
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.permissions,
      arguments: destino,
    );
  }
}
