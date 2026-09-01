import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'package:doctorly/utils/design_tokens.dart';

/// Skeleton loading widget matching the healthcare design specs of DoctorCard.
class DoctorCardSkeleton extends StatelessWidget {
  /// Creates a [DoctorCardSkeleton] instance.
  const DoctorCardSkeleton({super.key, this.compact = false});

  /// Whether compact margin should be used.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 350.0, minHeight: 99.0),
      margin: compact
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(
              horizontal: DesignTokens.md,
              vertical: DesignTokens.sm,
            ),
      padding: const EdgeInsets.all(DesignTokens.sm + DesignTokens.xs),
      decoration: BoxDecoration(
        color: DesignTokens.cardBackground,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
        boxShadow: const [DesignTokens.cardShadow],
      ),
      child: Shimmer.fromColors(
        baseColor: DesignTokens.divider,
        highlightColor: DesignTokens.cardBackground,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Side Avatar (60x60)
            Container(
              width: 60.0,
              height: 60.0,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: DesignTokens.sm + DesignTokens.xs),

            // Middle Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Container(
                          height: 16.0,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(DesignTokens.radiusSmall / 2),
                          ),
                        ),
                      ),
                      const SizedBox(width: DesignTokens.sm),
                      Container(
                        width: 36.0,
                        height: 16.0,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: DesignTokens.sm),
                  Container(
                    height: 14.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(DesignTokens.radiusSmall / 2),
                    ),
                  ),
                  const SizedBox(height: DesignTokens.sm + DesignTokens.xs),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Container(
                          height: 14.0,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(DesignTokens.radiusSmall / 2),
                          ),
                        ),
                      ),
                      const SizedBox(width: DesignTokens.sm),
                      Container(
                        width: 60.0,
                        height: 28.0,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
