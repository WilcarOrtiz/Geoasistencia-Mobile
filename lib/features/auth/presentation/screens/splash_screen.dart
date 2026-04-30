import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    final session = Supabase.instance.client.auth.currentSession;

    // ¿Ya vio el onboarding antes?
    final vioOnboarding = StorageService.getData('onboarding') == 'true';

    if (!context.mounted) return;
    if (session != null) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else if (!vioOnboarding) {
      Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }
}
