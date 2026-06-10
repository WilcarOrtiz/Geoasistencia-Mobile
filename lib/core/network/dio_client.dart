import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// [DioClient] centraliza toda la configuración de Dio:
///
/// - Adjunta el Bearer token de Supabase a cada request
/// - Refresca el token si está próximo a expirar ANTES de enviar la request
/// - En caso de 401, intenta refrescar y reintentar UNA vez
/// - Si el refresco falla (sesión inválida), cierra sesión en Supabase
///   y dispara el navegador hacia login via callback
class DioClient {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: dotenv.env['API_URL']!,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  static Dio get instance => _dio;

  /// Callback para redirigir a login cuando la sesión es inválida.
  /// Debe ser asignado en main.dart o en el widget raíz.
  static VoidCallback? onUnauthorized;

  static void init() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final session = Supabase.instance.client.auth.currentSession;

          if (session != null) {
            // Refrescar token proactivamente si expira en menos de 60s
            final expiresAt = session.expiresAt;
            final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

            if (expiresAt != null && expiresAt - now < 60) {
              try {
                await Supabase.instance.client.auth.refreshSession();
                debugPrint('[Dio] Token refrescado proactivamente');
              } catch (e) {
                debugPrint('[Dio] Error refrescando token proactivo: $e');
              }
            }

            final token =
                Supabase.instance.client.auth.currentSession?.accessToken;

            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }

          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            try {
              // Intentar refrescar el token
              await Supabase.instance.client.auth.refreshSession();
              final newToken =
                  Supabase.instance.client.auth.currentSession?.accessToken;

              if (newToken != null) {
                // Reintentar la request original con el nuevo token
                final opts = Options(
                  method: error.requestOptions.method,
                  headers: {
                    ...error.requestOptions.headers,
                    'Authorization': 'Bearer $newToken',
                  },
                );

                final retryResponse = await _dio.request(
                  error.requestOptions.path,
                  data: error.requestOptions.data,
                  queryParameters: error.requestOptions.queryParameters,
                  options: opts,
                );

                return handler.resolve(retryResponse);
              }
            } catch (e) {
              debugPrint('[Dio] Error en retry 401: $e');
              // Sesión inválida: cerrar sesión y redirigir a login
              await Supabase.instance.client.auth.signOut();
              onUnauthorized?.call();
            }
          }

          // Extraer mensaje de error del response
          String message = 'Error inesperado';

          if (error.response?.data is Map) {
            final data = error.response?.data as Map;
            if (data['message'] != null) {
              final msg = data['message'];
              message = msg is List ? msg.join(', ') : msg.toString();
            }
          } else if (error.error != null) {
            message = error.error.toString();
          }

          handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              error: message,
              response: error.response,
              type: error.type,
            ),
          );
        },
      ),
    );
  }
}
