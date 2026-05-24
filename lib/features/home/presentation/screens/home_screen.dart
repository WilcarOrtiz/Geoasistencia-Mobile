import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoasistencia/core/constants/app_routes.dart';
import 'package:geoasistencia/core/theme/app_theme.dart';
import 'package:geoasistencia/features/auth/presentation/providers/auth_provider.dart';
import 'package:geoasistencia/features/groups/presentation/providers/groups_provider.dart';
import 'package:geoasistencia/features/groups/presentation/widgets/groups_teacher_view.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authData = ref.watch(authProvider).asData?.value;
    final user = authData?.user;
    final grupos = ref.watch(groupsProvider);

    final firstName = user?.fullName.split(' ').first ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: GreenGradientBackground(
        child: CustomScrollView(
          slivers: [
            // ── App Bar ──────────────────────────────────────
            SliverAppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              expandedHeight: 180,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: _HeaderBanner(
                  firstName: firstName,
                  role: authData?.roles.map((r) => r.name).join(', ') ?? '',
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _LogoutButton(ref: ref, context: context),
                ),
              ],
            ),

            // ── Section title ────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: SectionHeader(title: 'Mis Grupos'),
              ),
            ),

            // ── Groups list ──────────────────────────────────
            grupos.when(
              loading: () => const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
              error: (e, _) => SliverFillRemaining(
                child: _ErrorState(message: e.toString()),
              ),
              data: (paginado) => paginado.data.isEmpty
                  ? const SliverFillRemaining(child: _EmptyState())
                  : SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, i) => GroupsListView(grupos: paginado.data),
                          childCount: 1,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header Banner ─────────────────────────────────────────────────

class _HeaderBanner extends StatelessWidget {
  final String firstName;
  final String role;

  const _HeaderBanner({required this.firstName, required this.role});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 16,
        20,
        20,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryLight],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: AppRadius.smBr,
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hola, $firstName 👋',
                    style: AppTextStyles.h2.copyWith(color: Colors.white),
                  ),
                  Text(
                    role,
                    style: AppTextStyles.bodySm.copyWith(
                      color: Colors.white.withOpacity(0.75),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Logout button ─────────────────────────────────────────────────

class _LogoutButton extends StatelessWidget {
  final WidgetRef ref;
  final BuildContext context;

  const _LogoutButton({required this.ref, required this.context});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        await ref.read(authProvider.notifier).logout();
        if (!context.mounted) return;
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      },
      icon: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: AppRadius.smBr,
        ),
        child: const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
      ),
    );
  }
}

// ── States ────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: AppRadius.xlBr,
            ),
            child: const Icon(
              Icons.folder_open_rounded,
              size: 48,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text('Sin grupos asignados', style: AppTextStyles.h2),
          const SizedBox(height: 6),
          Text(
            'No tienes ningún grupo asignado aún.',
            style: AppTextStyles.bodyMd,
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text('Ocurrió un error', style: AppTextStyles.h2),
            const SizedBox(height: 6),
            Text(
              message,
              style: AppTextStyles.bodyMd,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
