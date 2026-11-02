import 'package:flutter/material.dart';

/// Paleta de colores de Farma-Di.
class AppColors {
  AppColors._();

  // Fondos y superficies del tema claro.
  static const Color background = Color(0xFFF4F6FA);
  static const Color surface = Colors.white;

  // Texto del tema claro.
  static const Color textPrimary = Color(0xFF162238);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);

  // Acentos principales.
  static const Color primary = Color(0xFF2F6FE4);
  static const Color primarySoft = Color(0xFFE8F0FE);

  // Estados y etiquetas.
  static const Color success = Color(0xFF16A34A);
  static const Color successSoft = Color(0xFFE3F7EA);
  static const Color warning = Color(0xFFE07A28);
  static const Color warningSoft = Color(0xFFFCEEE0);

  // Iconos de las tarjetas estadísticas.
  static const Color amber = Color(0xFFE0A438);
  static const Color amberSoft = Color(0xFFFBF1DD);
  static const Color purple = Color(0xFF8B7FE0);
  static const Color purpleSoft = Color(0xFFEFEDFC);
  static const Color red = Color(0xFFE0645F);
  static const Color redSoft = Color(0xFFFBE9E8);

  // Panel de perfil.
  static const Color profileCard = Color(0xFF1E293F);

  // Colores de la pantalla de inicio de sesión.
  static const Color ink = Color(0xFF2C3E50);
  static const Color sheet = Color(0xFFF4F5F5);
  static const Color accent = Color(0xFF3B9BE0);
  static const Color link = Color(0xFF2F80C4);
  static const Color track = Color(0xFFE6E9EC);
  static const Color border = Color(0xFFDDE2E6);
  static const Color muted = Color(0xFF6B7782);
  static const Color hint = Color(0xFF9AA4AD);
  static const Color onInkMuted = Color(0xFFAAB6C2);

  // Métricas y gráficos.
  static const Color primaryDark = Color(0xFF1E2A3A);
  static const Color chartBlue = Color(0xFF3B8FD9);
  static const Color positiveGreen = Color(0xFF22B36B);
  static const Color neutralGray = Color(0xFFC5CCD8);
  static const Color mutedText = Color(0xFF8A94A6);
  static const Color trackBackground = Color(0xFFE9EDF3);
  static const Color warningOrange = Color(0xFFE08A00);
  static const Color warningBackground = Color(0xFFFFF1DC);
  static const Color positiveBackground = Color(0xFFDDF5E7);
  static const Color infoBackground = Color(0xFFDDEBFA);

  // Colores semánticos adaptables al tema activo.
  static Color backgroundOf(BuildContext context) =>
      Theme.of(context).scaffoldBackgroundColor;

  static Color surfaceOf(BuildContext context) =>
      Theme.of(context).colorScheme.surface;

  static Color textPrimaryOf(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;

  static Color textSecondaryOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFFB8C2D1)
      : textSecondary;

  static Color borderOf(BuildContext context) => Theme.of(context).dividerColor;
}
