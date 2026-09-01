import 'package:flutter/material.dart';

/// Centralized design tokens for Doctorly design system.
abstract final class DesignTokens {
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

  /// Custom shadow token for cards and elevated components.
  static const BoxShadow cardShadow = BoxShadow(
    color: Color(0x0A1A2B33),
    blurRadius: 16,
    offset: Offset(0, 4),
  );
}
