import 'package:flutter/material.dart';

import 'package:doctorly/features/doctor/presentation/widgets/verified_explainer_sheet.dart';
import 'package:doctorly/utils/design_tokens.dart';
import 'package:doctorly/utils/doctor_strings.dart';

/// A badge displaying verification state:
/// - Full verification: teal pill with verified checkmark and 'Verified' text.
/// - Partial verification: amber pill with pending icon and 'Pending verification' text.
/// - Unverified: should not be displayed.
///
/// Tapping the badge opens [VerifiedExplainerSheet] explaining the standards.
class VerifiedBadge extends StatelessWidget {
  /// Creates a [VerifiedBadge] instance.
  const VerifiedBadge({
    super.key,
    this.compact = false,
    this.partiallyVerified = false,
  });

  /// Whether to render a smaller, compact variant of the badge.
  final bool compact;

  /// Whether the doctor profile is partially verified.
  final bool partiallyVerified;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final badgeColor = partiallyVerified ? DesignTokens.warning : DesignTokens.primary;
    final labelText = partiallyVerified ? DoctorStrings.pendingStatus : DoctorStrings.verifiedStatus;
    final iconData = partiallyVerified ? Icons.pending_outlined : Icons.verified;

    return GestureDetector(
      onTap: () => VerifiedExplainerSheet.show(context),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? (DesignTokens.sm - DesignTokens.xs / 2) : DesignTokens.sm,
          vertical: compact ? (DesignTokens.xs / 2) : DesignTokens.xs,
        ),
        decoration: BoxDecoration(
          color: badgeColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
          border: Border.all(
            color: badgeColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              iconData,
              color: badgeColor,
              size: compact ? 12 : 14,
            ),
            const SizedBox(width: DesignTokens.xs),
            Flexible(
              child: Text(
                labelText,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: badgeColor,
                  fontWeight: FontWeight.w600,
                  fontSize: compact ? 10 : 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
