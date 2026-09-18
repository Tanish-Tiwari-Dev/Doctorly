import 'package:flutter/material.dart';

import 'package:doctorly/utils/design_tokens.dart';
import 'package:doctorly/utils/disha_categories.dart';
import 'package:doctorly/utils/doctor_strings.dart';

/// Modal bottom sheet displaying a plain-language explainer for a Disha category.
/// Explains "What is this?" and "When would I need it?" in 2-3 sentences each,
/// without giving medical advice, ending with the medical disclaimer.
class CategoryExplainerSheet extends StatelessWidget {
  const CategoryExplainerSheet({
    super.key,
    required this.categorySlug,
    this.scrollController,
  });

  final String categorySlug;
  final ScrollController? scrollController;


  /// Shows the category explainer bottom sheet modal.
  static Future<void> show(BuildContext context, String categorySlug) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: DesignTokens.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(DesignTokens.radiusLarge),
        ),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return CategoryExplainerSheet(
            categorySlug: categorySlug,
            scrollController: scrollController,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final explainer = DoctorStrings.getCategoryExplainer(categorySlug);

    final category = dishaCategories.firstWhere(
      (c) => c.slug == categorySlug,
      orElse: () => const DishaCategory(
        slug: '',
        title: '',
        serviceSlugs: [],
        icon: Icons.medical_services_outlined,
      ),
    );

    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.all(DesignTokens.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
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

          // Header with category icon and title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(DesignTokens.sm),
                decoration: BoxDecoration(
                  color: DesignTokens.primaryLight,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
                ),
                child: Icon(
                  category.icon,
                  color: DesignTokens.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: DesignTokens.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DoctorStrings.categoryExplainerTitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: DesignTokens.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      explainer.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: DesignTokens.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.lg),

          // "What is this?" block
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(DesignTokens.md),
            decoration: BoxDecoration(
              color: DesignTokens.inputBackground,
              borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.help_outline_rounded,
                      size: 18,
                      color: DesignTokens.primary,
                    ),
                    const SizedBox(width: DesignTokens.xs),
                    Text(
                      DoctorStrings.categoryWhatIsThis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: DesignTokens.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DesignTokens.xs),
                Text(
                  explainer.whatIsThis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: DesignTokens.textPrimary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: DesignTokens.md),

          // "When would I need it?" block
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(DesignTokens.md),
            decoration: BoxDecoration(
              color: DesignTokens.inputBackground,
              borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                      color: DesignTokens.secondary,
                    ),
                    const SizedBox(width: DesignTokens.xs),
                    Text(
                      DoctorStrings.categoryWhenNeeded,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: DesignTokens.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DesignTokens.xs),
                Text(
                  explainer.whenNeeded,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: DesignTokens.textPrimary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: DesignTokens.md),

          // Medical Disclaimer Notice
          Container(
            padding: const EdgeInsets.all(DesignTokens.sm + DesignTokens.xs),
            decoration: BoxDecoration(
              color: DesignTokens.warningBackground,
              borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
              border: Border.all(
                color: DesignTokens.warning.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: DesignTokens.warning,
                  size: 20,
                ),
                const SizedBox(width: DesignTokens.sm),
                Expanded(
                  child: Text(
                    DoctorStrings.disclaimerBody,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: DesignTokens.textPrimary,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: DesignTokens.lg),

          // Dismiss Button
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
                padding: const EdgeInsets.symmetric(
                  vertical: DesignTokens.sm + DesignTokens.xs,
                ),
              ),
              child: const Text('Understood'),
            ),
          ),
        ],
      ),
    );
  }
}
