import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoasistencia/core/services/permission_service.dart';
import 'package:geoasistencia/core/utils/storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geoasistencia/core/constants/app_routes.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // ✅ Solo se llama UNA vez, no en cada rebuild
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  Future<void> _init() async {
    await Future.delayed(const Duration(seconds: 1));
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
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
