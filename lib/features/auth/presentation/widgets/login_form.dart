import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoasistencia/core/constants/app_routes.dart';
import 'package:geoasistencia/core/errors/auth_exceptions.dart';
import 'package:geoasistencia/core/services/permission_service.dart';
import 'package:geoasistencia/core/utils/app_toast.dart';
import 'package:geoasistencia/features/auth/presentation/providers/auth_provider.dart';

class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({super.key});

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    ref
        .read(authProvider.notifier)
        .login(_emailCtrl.text.trim(), _passwordCtrl.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authProvider);

    ref.listen(authProvider, (_, next) {
      next.whenOrNull(
        data: (_) async {
          final permsOk = await PermissionService.allGranted();
          if (!context.mounted) return;

          if (permsOk) {
            Navigator.pushReplacementNamed(context, AppRoutes.home);
          } else {
            Navigator.pushReplacementNamed(
              context,
              AppRoutes.permissions,
              arguments: AppRoutes.home,
            );
          }
        },
        error: (e, _) {
          switch (e) {
            case InvalidCredentialsException():
              AppToast.error(
                context,
                e.message,
                title: 'Credenciales incorrectas',
              );
            case UserNotFoundException():
              AppToast.error(context, e.message, title: 'Usuario sin acceso');
            case ServerException():
              AppToast.error(context, e.message, title: 'Error del servidor');
            default:
              AppToast.error(context, e.toString(), title: 'Error inesperado');
          }
        },
      );
    });

    return AutofillGroup(
      child: Column(
        children: [
          TextField(
            controller: _emailCtrl,
            decoration: const InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordCtrl,
            decoration: const InputDecoration(labelText: 'Contraseña'),
            obscureText: true,
            autofillHints: const [AutofillHints.password],
          ),
          const SizedBox(height: 24),
          state.isLoading
              ? const CircularProgressIndicator()
              : SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    child: const Text('Ingresar'),
                  ),
                ),
        ],
      ),
    );
  }
}
