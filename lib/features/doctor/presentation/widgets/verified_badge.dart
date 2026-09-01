import 'package:flutter/material.dart';

import 'package:doctorly/utils/app_colors.dart';
import 'package:doctorly/utils/design_tokens.dart';

/// A small, elegant badge displaying a verified checkmark icon and text.
class VerifiedBadge extends StatelessWidget {
  /// Creates a [VerifiedBadge] instance.
  const VerifiedBadge({super.key, this.compact = false});

  /// Whether to render a smaller, compact variant of the badge.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? (DesignTokens.sm - DesignTokens.xs / 2) : DesignTokens.sm,
        vertical: compact ? (DesignTokens.xs / 2) : DesignTokens.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified,
            color: AppColors.primary,
            size: compact ? 12 : 14,
          ),
          const SizedBox(width: DesignTokens.xs),
          Text(
            'Verified',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: compact ? 10 : 11,
                ),
          ),
        ],
      ),
    );
  }
}
