import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF4648D4);
  static const secondary = Color(0xFF8127CF);
  static const teal = Color(0xFF006B5F);

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  // Background
  static Color background(BuildContext context) => isDark(context)
      ? const Color(0xFF0A0A0B)
      : const Color(0xFFF4F3FF); // light indigo tint

  // Card
  static Color cardColor(BuildContext context) =>
      isDark(context) ? Colors.white.withOpacity(0.03) : Colors.white;

  // Border
  static Color borderColor(BuildContext context) => isDark(context)
      ? Colors.white.withOpacity(0.1)
      : const Color(0xFF4648D4).withOpacity(0.15);

  // Primary text
  static Color textPrimary(BuildContext context) =>
      isDark(context) ? Colors.white : const Color(0xFF1C1B1C);

  // Secondary text
  static Color textSecondary(BuildContext context) =>
      isDark(context) ? Colors.white.withOpacity(0.5) : const Color(0xFF464554);

  // Input fill
  static Color inputFill(BuildContext context) =>
      isDark(context) ? Colors.white.withOpacity(0.05) : Colors.white;

  // Ambient glow
  static Color ambientGlow(BuildContext context) => isDark(context)
      ? const Color(0xFF4648D4).withOpacity(0.08)
      : const Color(0xFF4648D4).withOpacity(0.05);

  // Nav bar
  static Color navBar(BuildContext context) => isDark(context)
      ? const Color(0xFF0A0A0B).withOpacity(0.95)
      : Colors.white;

  // Nav icon inactive
  static Color navInactive(BuildContext context) =>
      isDark(context) ? Colors.white.withOpacity(0.4) : Colors.grey.shade400;

  // Section label
  static Color sectionLabel(BuildContext context) =>
      isDark(context) ? Colors.white.withOpacity(0.4) : Colors.grey.shade500;

  // Input hint
  static Color inputHint(BuildContext context) =>
      isDark(context) ? Colors.white.withOpacity(0.25) : Colors.grey.shade400;

  // Box shadow
  static List<BoxShadow> cardShadow(BuildContext context) => [
        BoxShadow(
          color: isDark(context)
              ? Colors.black.withOpacity(0.3)
              : const Color(0xFF4648D4).withOpacity(0.08),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ];
}
