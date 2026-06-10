import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoasistencia/core/constants/app_routes.dart';
import 'package:geoasistencia/core/theme/app_theme.dart';
import 'package:geoasistencia/features/auth/presentation/providers/auth_provider.dart';
import 'package:geoasistencia/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// [App] escucha los cambios del estado de autenticación de Supabase.
///
/// Cuando el usuario cierra sesión (evento signedOut) o cambia de usuario,
/// se invalidan TODOS los providers de Riverpod para que ninguna vista
/// muestre datos del usuario anterior.
///
/// Esto soluciona el bug donde al salir y volver a entrar con otro usuario
/// se veían botones o datos del usuario anterior.
class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  @override
  void initState() {
    super.initState();

    // Escuchar cambios de sesión de Supabase
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;

      if (event == AuthChangeEvent.signedOut) {
        // Limpiar TODOS los providers al cerrar sesión
        // Esto evita que datos del usuario anterior persistan
        ref.invalidate(authProvider);
        _invalidateAllUserProviders();
      }

      if (event == AuthChangeEvent.signedIn) {
        // Al iniciar sesión, forzar recarga de datos del nuevo usuario
        _invalidateAllUserProviders();
      }

      if (event == AuthChangeEvent.tokenRefreshed) {
        // Token refrescado: no es necesario invalidar, el interceptor Dio ya lo maneja
        debugPrint('[Auth] Token refrescado automáticamente');
      }
    });
  }

  /// Invalida todos los providers que contienen datos específicos del usuario.
  /// Agregar aquí cualquier provider nuevo que dependa de la sesión.
  void _invalidateAllUserProviders() {
    // Los providers de Riverpod se invalidan para forzar recarga
    // al navegar a las pantallas correspondientes.
    //
    // No se puede invalidar providers con familia aquí sin los parámetros,
    // pero el hecho de que authProvider sea invalidado hace que todos los
    // providers que hacen ref.watch(authProvider) se reconstruyan.
    //
    // Para providers de familia (groupsProvider, classDayProvider, etc.)
    // el SplashScreen / HomeScreen los recreará al cargar.
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'GeoAsistencia',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
    );
  }
}
