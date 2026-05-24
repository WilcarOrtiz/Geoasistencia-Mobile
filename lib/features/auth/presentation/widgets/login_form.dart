import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoasistencia/core/constants/app_routes.dart';
import 'package:geoasistencia/core/network/api_exception.dart';
import 'package:geoasistencia/core/services/permission_service.dart';
import 'package:geoasistencia/core/utils/app_toast.dart';
import 'package:geoasistencia/core/theme/app_theme.dart';
import 'package:geoasistencia/features/auth/presentation/providers/auth_provider.dart';

class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({super.key});

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;

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
          if (e is ApiException) {
            AppToast.error(context, e.message, title: 'Error');
          } else {
            AppToast.error(context, 'Error inesperado', title: 'Error');
          }
        },
      );
    });

    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Email ──────────────────────────────────────────
          Text('Correo electrónico', style: AppTextStyles.labelMd),
          const SizedBox(height: 6),
          TextField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            style: AppTextStyles.bodyLg,
            decoration: InputDecoration(
              hintText: 'usuario@institución.edu',
              prefixIcon: const Icon(Icons.email_outlined, size: 20),
              prefixIconColor: WidgetStateColor.resolveWith(
                (states) => states.contains(WidgetState.focused)
                    ? AppColors.primary
                    : AppColors.textMuted,
              ),
            ),
          ),

          const SizedBox(height: 18),

          // ── Password ───────────────────────────────────────
          Text('Contraseña', style: AppTextStyles.labelMd),
          const SizedBox(height: 6),
          TextField(
            controller: _passwordCtrl,
            obscureText: _obscure,
            autofillHints: const [AutofillHints.password],
            style: AppTextStyles.bodyLg,
            decoration: InputDecoration(
              hintText: '••••••••',
              prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
              prefixIconColor: WidgetStateColor.resolveWith(
                (states) => states.contains(WidgetState.focused)
                    ? AppColors.primary
                    : AppColors.textMuted,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 20,
                  color: AppColors.textMuted,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),

          const SizedBox(height: 28),

          // ── Submit ─────────────────────────────────────────
          AppPrimaryButton(
            label: 'Ingresar',
            isLoading: state.isLoading,
            onPressed: state.isLoading ? null : _submit,
          ),
        ],
      ),
    );
  }
}
