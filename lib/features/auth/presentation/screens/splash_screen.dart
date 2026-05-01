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
    _checkSession(context);
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }

  void _checkSession(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 1));

    if (!context.mounted) return;

    final session = Supabase.instance.client.auth.currentSession;
    final vioOnboarding = StorageService.getData('onboarding') == 'true';

    // ── Determinar destino final (a donde ir DESPUÉS de permisos) ──────────
    late final String destino;
    if (session != null) {
      destino = AppRoutes.home;
    } else if (!vioOnboarding) {
      destino = AppRoutes.onboarding;
    } else {
      destino = AppRoutes.login;
    }

    // ── ¿Ya tiene todos los permisos? ──────────────────────────────────────
    // Si ya los tiene, verificamos igualmente los servicios (BT/GPS activos)
    // pasando por PermissionGateScreen, que es quien sabe manejar todo eso.
    // Así el flujo siempre pasa por la gate y la gate decide si hace algo.
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.permissions,
      arguments: destino, // le decimos a la gate a dónde ir después
    );
  }
}
