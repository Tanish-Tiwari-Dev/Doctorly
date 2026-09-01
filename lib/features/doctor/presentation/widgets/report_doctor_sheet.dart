import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:doctorly/features/doctor/data/repositories/reports_repository.dart';
import 'package:doctorly/services/logger.dart';
import 'package:doctorly/utils/app_colors.dart';
import 'package:doctorly/utils/design_tokens.dart';
import 'package:doctorly/utils/error_localizer.dart';

/// Modal bottom sheet widget for reporting doctor content or profiles.
class ReportDoctorSheet extends ConsumerStatefulWidget {
  const ReportDoctorSheet({
    super.key,
    required this.doctorId,
    required this.doctorName,
  });

  final String doctorId;
  final String doctorName;

  /// Helper static method to present the modal bottom sheet.
  static Future<void> show(
    BuildContext context, {
    required String doctorId,
    required String doctorName,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: DesignTokens.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(DesignTokens.radiusLarge),
        ),
      ),
      builder: (context) => ReportDoctorSheet(
        doctorId: doctorId,
        doctorName: doctorName,
      ),
    );
  }

  @override
  ConsumerState<ReportDoctorSheet> createState() => _ReportDoctorSheetState();
}

class _ReportDoctorSheetState extends ConsumerState<ReportDoctorSheet> {
  static const List<String> _predefinedReasons = [
    'Inaccurate information',
    'Fake profile',
    'Inappropriate behavior',
    'Other',
  ];

  String _selectedReason = _predefinedReasons.first;
  final TextEditingController _detailsController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      final repository = ref.read(reportsRepositoryProvider);
      final details = _detailsController.text.trim();

      await repository.submitReport(
        doctorId: widget.doctorId,
        reason: _selectedReason,
        details: details.isEmpty ? null : details,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.textPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
            ),
            content: Text(
              'Thank you. Your report has been submitted for review.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                  ),
            ),
          ),
        );
      }
    } catch (e, st) {
      LoggerService.instance.log.severe('Failed to submit doctor report', e, st);
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.error,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
            ),
            content: Text(
              localizeError(e),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                  ),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        DesignTokens.lg,
        DesignTokens.md + DesignTokens.xs,
        DesignTokens.lg,
        DesignTokens.md + DesignTokens.xs + bottomInset,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusSmall / 4),
                ),
              ),
            ),
            const SizedBox(height: DesignTokens.md),
            Row(
              children: [
                const Icon(
                  Icons.flag_outlined,
                  color: AppColors.error,
                  size: 24,
                ),
                const SizedBox(width: DesignTokens.sm + DesignTokens.xs),
                Expanded(
                  child: Text(
                    'Report ${widget.doctorName}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: DesignTokens.sm),
            Text(
              'Please select a reason for reporting this profile. Your report will be reviewed by our moderation team.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
            ),
            const SizedBox(height: DesignTokens.md),
            ..._predefinedReasons.map((reason) {
              final isSelected = reason == _selectedReason;
              return InkWell(
                onTap: _isSubmitting
                    ? null
                    : () {
                        setState(() => _selectedReason = reason);
                      },
                borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignTokens.xs,
                    vertical: DesignTokens.sm + DesignTokens.xs,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.inactiveIcon,
                        size: 22,
                      ),
                      const SizedBox(width: DesignTokens.sm + DesignTokens.xs),
                      Text(
                        reason,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: AppColors.textPrimary,
                            ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: DesignTokens.md),
            Text(
              'Additional Details (Optional)',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: DesignTokens.sm),
            TextField(
              controller: _detailsController,
              enabled: !_isSubmitting,
              maxLength: 500,
              maxLines: 3,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                  ),
              decoration: InputDecoration(
                hintText: 'Provide any additional context or details...',
                hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textHint,
                    ),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: DesignTokens.md),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.primary.withValues(
                    alpha: 0.5,
                  ),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
                  ),
                  textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Submit Report'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
