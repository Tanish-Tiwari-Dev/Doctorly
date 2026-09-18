import 'package:flutter/material.dart';

import 'package:doctorly/utils/design_tokens.dart';
import 'package:doctorly/utils/doctor_strings.dart';

/// Modal bottom sheet explaining verification standards and differences between
/// 'Verified' and 'Pending verification' statuses.
class VerifiedExplainerSheet extends StatelessWidget {
  const VerifiedExplainerSheet({super.key});

  /// Presents the bottom sheet modal.
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: DesignTokens.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(DesignTokens.radiusLarge),
        ),
      ),
      builder: (context) => const VerifiedExplainerSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(DesignTokens.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: DesignTokens.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: DesignTokens.md),
          Row(
            children: [
              const Icon(
                Icons.verified_user_rounded,
                color: DesignTokens.primary,
                size: 26,
              ),
              const SizedBox(width: DesignTokens.sm),
              Text(
                DoctorStrings.verifiedExplainerTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: DesignTokens.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.md),

          // Verified Pill explanation
          Container(
            padding: const EdgeInsets.all(DesignTokens.sm + DesignTokens.xs),
            decoration: BoxDecoration(
              color: DesignTokens.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
              border: Border.all(
                color: DesignTokens.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.verified,
                  color: DesignTokens.primary,
                  size: 20,
                ),
                const SizedBox(width: DesignTokens.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Verified Profile',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: DesignTokens.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Medical registration number, credentials, and hospital affiliations have been verified against official council registries.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: DesignTokens.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: DesignTokens.sm),

          // Pending verification Pill explanation
          Container(
            padding: const EdgeInsets.all(DesignTokens.sm + DesignTokens.xs),
            decoration: BoxDecoration(
              color: DesignTokens.warning.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
              border: Border.all(
                color: DesignTokens.warning.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.pending_outlined,
                  color: DesignTokens.warning,
                  size: 20,
                ),
                const SizedBox(width: DesignTokens.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pending Verification',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: DesignTokens.warning,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Listing information has been extracted from public institutional sources and is actively undergoing verification by our team.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: DesignTokens.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: DesignTokens.md),

          Text(
            'We do not accept payments to verify or feature doctors. Every profile is evaluated based on publicly verifiable institutional records.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: DesignTokens.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: DesignTokens.lg),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignTokens.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
                ),
                padding: const EdgeInsets.symmetric(vertical: DesignTokens.sm + DesignTokens.xs),
              ),
              child: const Text('Understood'),
            ),
          ),
        ],
      ),
    );
  }
}
