import 'package:flutter/material.dart';

/// Centralized design tokens for Doctorly design system.
///
/// Defines spacing, radius, colour, and shadow tokens used
/// throughout the application to ensure a consistent
/// "Pleasant, Trustworthy, and Soft" healthcare aesthetic.
abstract final class DesignTokens {
  // ──────────────────────────── Spacing ─────────────────────────────

  /// Extra small spacing (4.0). Use strictly for paddings/margins.
  static const double xs = 4.0;

  /// Small spacing (8.0). Use strictly for paddings/margins.
  static const double sm = 8.0;

  /// Medium spacing (16.0). Use strictly for paddings/margins.
  static const double md = 16.0;

  /// Large spacing (24.0). Use strictly for paddings/margins.
  static const double lg = 24.0;

  /// Extra large spacing (32.0). Use strictly for paddings/margins.
  static const double xl = 32.0;

  // ──────────────────────────── Radii ───────────────────────────────

  /// Small border radius (8.0).
  static const double small = 8.0;

  /// Medium border radius (16.0).
  static const double medium = 16.0;

  /// Large border radius (24.0).
  static const double large = 24.0;

  /// Extra large border radius (32.0).
  static const double radiusXl = 32.0;

  /// Alias for small border radius (8.0).
  static const double radiusSmall = 8.0;

  /// Alias for medium border radius (16.0).
  static const double radiusMedium = 16.0;

  /// Alias for large border radius (24.0).
  static const double radiusLarge = 24.0;

  // ──────────────────────── Core Colours ────────────────────────────

  /// Deep, calming teal — conveys trust and stability.
  static const Color primary = Color(0xFF2D6A6E);

  /// Soft primary tint for chips, badges, and light backgrounds.
  static const Color primaryLight = Color(0xFFE0F2F1);

  /// Scaffold / page background — very soft, cool off-white.
  static const Color scaffoldBackground = Color(0xFFF8FAFC);

  /// Card surface colour — pure white so cards pop against the bg.
  static const Color cardBackground = Color(0xFFFFFFFF);

  /// Input surface colour — soft slate grey for text fields / search inputs.
  static const Color inputBackground = Color(0xFFF1F5F9);

  /// Soft border / divider colour (Slate 200).
  static const Color divider = Color(0xFFE2E8F0);

  // ──────────────────────── Text Colours ────────────────────────────

  /// Primary text — pleasant dark grey instead of pure black (Slate 800).
  static const Color textPrimary = Color(0xFF1E293B);

  /// Secondary / muted text (Slate 500).
  static const Color textSecondary = Color(0xFF64748B);

  // ──────────────────── Semantic / Status Colours ───────────────────

  /// Success / Open indicator (Soft Green).
  static const Color success = Color(0xFF16A34A);

  /// Light background for success chips and banners.
  static const Color successBackground = Color(0xFFF0FDF4);

  /// Error / Closed indicator (Soft Red).
  static const Color error = Color(0xFFDC2626);

  /// Light background for error chips and banners.
  static const Color errorBackground = Color(0xFFFEF2F2);

  /// Star / rating colour (Warm Amber).
  static const Color starRating = Color(0xFFF59E0B);

  // ──────────────────────── Shadows ─────────────────────────────────

  /// Custom shadow token for cards and elevated components.
  /// Very soft, slate-tinted shadow for a floating-paper feel.
  static const BoxShadow cardShadow = BoxShadow(
    color: Color(0x0F1E293B),
    blurRadius: 15,
    offset: Offset(0, 4),
  );

  /// Subtle shadow for smaller cards or search inputs.
  static const BoxShadow subtleShadow = BoxShadow(
    color: Color(0x0A1E293B),
    blurRadius: 10,
    offset: Offset(0, 2),
  );
}
