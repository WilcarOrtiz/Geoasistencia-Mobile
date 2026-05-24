/*import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
    useMaterial3: true,
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
  );
}
*/

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────────────────────────
//  GeoAsistencia Design System – Token Reference
//  Inspirado en la paleta verde institucional UPC
// ─────────────────────────────────────────────────────────────────

abstract class AppColors {
  // ── Verdes institucionales ────────────────────────────────────
  static const primary = Color(0xFF2D7A45); // verde UPC principal
  static const primaryLight = Color(0xFF3D9A5A); // hover / pressed
  static const primaryDark = Color(0xFF1F5A32); // sombra / bordes
  static const primarySurface = Color(0xFFE8F5ED); // fondo suave verde
  static const primaryMuted = Color(0xFFB7DCC5); // borde suave / placeholder

  // ── Semánticos ───────────────────────────────────────────────
  static const success = Color(0xFF22C55E);
  static const successSurface = Color(0xFFDCFCE7);
  static const warning = Color(0xFFF59E0B);
  static const warningSurface = Color(0xFFFEF3C7);
  static const error = Color(0xFFEF4444);
  static const errorSurface = Color(0xFFFEE2E2);
  static const info = Color(0xFF3B82F6);
  static const infoSurface = Color(0xFFEFF6FF);

  // ── Neutros ──────────────────────────────────────────────────
  static const background = Color(0xFFF7FAF8); // blanco verdoso muy suave
  static const surface = Color(0xFFFFFFFF);
  static const surfaceVariant = Color(0xFFF1F5F2);
  static const border = Color(0xFFDDE8E1);
  static const borderSubtle = Color(0xFFEDF2EF);

  // ── Textos ───────────────────────────────────────────────────
  static const onPrimary = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF1A2E23); // foreground oscuro verde
  static const textSecondary = Color(0xFF4B6655);
  static const textMuted = Color(0xFF8BA898);
  static const textDisabled = Color(0xFFB8C9BF);

  // ── Status badges ────────────────────────────────────────────
  static const present = Color(0xFF22C55E);
  static const presentSurface = Color(0xFFDCFCE7);
  static const late = Color(0xFFF59E0B);
  static const lateSurface = Color(0xFFFEF3C7);
  static const absent = Color(0xFFEF4444);
  static const absentSurface = Color(0xFFFEE2E2);
}

abstract class AppRadius {
  static const double xs = 6;
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 18;
  static const double xl = 24;
  static const double xxl = 32;
  static const double full = 999;

  static BorderRadius get xsBr => BorderRadius.circular(xs);
  static BorderRadius get smBr => BorderRadius.circular(sm);
  static BorderRadius get mdBr => BorderRadius.circular(md);
  static BorderRadius get lgBr => BorderRadius.circular(lg);
  static BorderRadius get xlBr => BorderRadius.circular(xl);
  static BorderRadius get xxlBr => BorderRadius.circular(xxl);
  static BorderRadius get fullBr => BorderRadius.circular(full);
}

abstract class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: 20,
    vertical: 16,
  );
  static const EdgeInsets cardPadding = EdgeInsets.all(16);
  static const EdgeInsets sectionPadding = EdgeInsets.symmetric(horizontal: 20);
}

abstract class AppShadows {
  static List<BoxShadow> get card => [
    BoxShadow(
      color: AppColors.primary.withOpacity(0.06),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> get elevated => [
    BoxShadow(
      color: AppColors.primary.withOpacity(0.14),
      blurRadius: 32,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get subtle => [
    BoxShadow(
      color: AppColors.primary.withOpacity(0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
}

abstract class AppTextStyles {
  // ── Display ──────────────────────────────────────────────────
  static const TextStyle displayLg = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -0.8,
    height: 1.2,
  );
  static const TextStyle displayMd = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.25,
  );
  static const TextStyle displaySm = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
    height: 1.3,
  );

  // ── Headings ─────────────────────────────────────────────────
  static const TextStyle h1 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
  );
  static const TextStyle h2 = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  static const TextStyle h3 = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // ── Body ─────────────────────────────────────────────────────
  static const TextStyle bodyLg = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );
  static const TextStyle bodyMd = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );
  static const TextStyle bodySm = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
    height: 1.4,
  );

  // ── Labels ───────────────────────────────────────────────────
  static const TextStyle labelLg = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0.1,
  );
  static const TextStyle labelMd = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 0.1,
  );
  static const TextStyle labelSm = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
    letterSpacing: 0.3,
  );

  // ── Monospace / Código ────────────────────────────────────────
  static const TextStyle mono = TextStyle(
    fontFamily: 'monospace',
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.primary,
    letterSpacing: 8,
  );
}

// ─────────────────────────────────────────────────────────────────
//  ThemeData principal
// ─────────────────────────────────────────────────────────────────
class AppTheme {
  static ThemeData get light {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primarySurface,
      onPrimaryContainer: AppColors.primaryDark,
      secondary: AppColors.primaryLight,
      onSecondary: AppColors.onPrimary,
      secondaryContainer: AppColors.primarySurface,
      onSecondaryContainer: AppColors.textPrimary,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      surfaceContainerHighest: AppColors.surfaceVariant,
      error: AppColors.error,
      onError: Colors.white,
      outline: AppColors.border,
      outlineVariant: AppColors.borderSubtle,
      shadow: Colors.black12,
      scrim: Colors.black54,
      inverseSurface: AppColors.textPrimary,
      onInverseSurface: AppColors.surface,
      inversePrimary: AppColors.primaryMuted,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Nunito',

      // ── AppBar ───────────────────────────────────────────────
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        titleTextStyle: AppTextStyles.h1,
        iconTheme: IconThemeData(color: AppColors.textPrimary, size: 22),
      ),

      // ── Card ─────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.lgBr,
          side: const BorderSide(color: AppColors.borderSubtle, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // ── Input ─────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.mdBr,
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdBr,
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdBr,
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdBr,
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        labelStyle: AppTextStyles.labelMd,
        hintStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.textDisabled),
      ),

      // ── ElevatedButton ────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.mdBr),
          textStyle: AppTextStyles.labelLg,
        ),
      ),

      // ── FilledButton ──────────────────────────────────────────
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.mdBr),
          textStyle: AppTextStyles.labelLg,
        ),
      ),

      // ── OutlinedButton ────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.mdBr),
          textStyle: AppTextStyles.labelLg,
        ),
      ),

      // ── TextButton ────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTextStyles.labelMd,
        ),
      ),

      // ── Divider ───────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.borderSubtle,
        thickness: 1,
        space: 1,
      ),

      // ── CircularProgressIndicator ─────────────────────────────
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
      ),

      // ── ListTile ──────────────────────────────────────────────
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        titleTextStyle: AppTextStyles.h3,
        subtitleTextStyle: AppTextStyles.bodyMd,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Componentes reutilizables del Design System
// ─────────────────────────────────────────────────────────────────

/// Tarjeta base con sombra y borde sutil
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? color;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: AppRadius.lgBr,
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: AppShadows.card,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.lgBr,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.lgBr,
          splashColor: AppColors.primary.withOpacity(0.06),
          highlightColor: AppColors.primary.withOpacity(0.04),
          child: Padding(
            padding: padding ?? AppSpacing.cardPadding,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Badge de estado (Presente / Tarde / Ausente)
class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color surfaceColor;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    required this.surfaceColor,
    this.icon,
  });

  factory StatusBadge.present({String label = 'Presente'}) => StatusBadge(
    label: label,
    color: AppColors.present,
    surfaceColor: AppColors.presentSurface,
    icon: Icons.check_circle_rounded,
  );

  factory StatusBadge.late({String label = 'Tarde'}) => StatusBadge(
    label: label,
    color: AppColors.late,
    surfaceColor: AppColors.lateSurface,
    icon: Icons.watch_later_rounded,
  );

  factory StatusBadge.absent({String label = 'Ausente'}) => StatusBadge(
    label: label,
    color: AppColors.absent,
    surfaceColor: AppColors.absentSurface,
    icon: Icons.cancel_rounded,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: AppRadius.fullBr,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTextStyles.labelSm.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Botón primario grande (full width)
class AppPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;

  const AppPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.primaryMuted,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.mdBr),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: AppTextStyles.labelLg.copyWith(color: Colors.white),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Botón secundario outlined
class AppOutlinedButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;

  const AppOutlinedButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: c,
          side: BorderSide(color: c, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.mdBr),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20),
              const SizedBox(width: 8),
            ],
            Text(label, style: AppTextStyles.labelLg.copyWith(color: c)),
          ],
        ),
      ),
    );
  }
}

/// Chip de información (icono + texto)
class InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? iconColor;

  const InfoChip({
    super.key,
    required this.icon,
    required this.label,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: AppRadius.smBr,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: iconColor ?? AppColors.primary),
          const SizedBox(width: 6),
          Text(label, style: AppTextStyles.labelMd),
        ],
      ),
    );
  }
}

/// Sección con título
class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const SectionHeader({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: AppTextStyles.h2),
        if (trailing != null) ...[const Spacer(), trailing!],
      ],
    );
  }
}

/// Fondo degradado verde institucional
class GreenGradientBackground extends StatelessWidget {
  final Widget child;

  const GreenGradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF0FAF4), Color(0xFFE8F5ED), Color(0xFFF7FAF8)],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: child,
    );
  }
}
