import 'package:flutter/material.dart';

/// Legacy colour aliases — delegates to [DesignTokens] where possible.
///
/// New code should prefer [DesignTokens] directly; these aliases exist to
/// keep existing widget imports working without mass-renames.
class AppColors {
  AppColors._();

  /// Soft avatar placeholder background.
  static const avatarBackground = Color(0xFFE0F2F1);

  /// Success / open indicator.
  static const success = Color(0xFF16A34A);

  /// Warning / amber accent.
  static const warning = Color(0xFFF59E0B);

  /// Error / closed indicator.
  static const error = Color(0xFFDC2626);

  /// Soft divider colour.
  static const divider = Color(0xFFE2E8F0);

  /// Secondary accent colour / gradient destination.
  static const secondary = Color(0xFF38BDF8);

  /// Secondary gradient accent.
  static const gradientSecondary = Color(0xFF38BDF8);

  /// Inactive navigation icon colour.
  static const inactiveIcon = Color(0xFF94A3B8);

  /// Inactive favourite heart colour.
  static const inactiveFavorite = Color(0xFF94A3B8);

  /// Hint / placeholder text.
  static const textHint = Color(0xFF94A3B8);

  /// Primary text — pleasant dark grey (Slate 800).
  static const textPrimary = Color(0xFF1E293B);

  /// Secondary / muted text (Slate 500).
  static const textSecondary = Color(0xFF64748B);

  /// Scaffold background — soft off-white (Slate 50).
  static const background = Color(0xFFF8FAFC);

  /// Brand primary — deep calming teal.
  static const primary = Color(0xFF2D6A6E);
}
