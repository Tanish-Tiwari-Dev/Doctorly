import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:doctorly/features/doctor/domain/models/specialty.dart';
import 'package:doctorly/features/doctor/presentation/providers/doctor_filter_provider.dart';
import 'package:doctorly/utils/app_colors.dart';
import 'package:doctorly/utils/design_tokens.dart';

/// Modal bottom sheet widget for setting doctor search filters.
class DoctorFilterSheet extends ConsumerStatefulWidget {
  /// Creates a [DoctorFilterSheet] instance.
  const DoctorFilterSheet({super.key});

  /// Helper static method to present the filter bottom sheet modal.
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
      builder: (context) => const DoctorFilterSheet(),
    );
  }

  @override
  ConsumerState<DoctorFilterSheet> createState() => _DoctorFilterSheetState();
}

class _DoctorFilterSheetState extends ConsumerState<DoctorFilterSheet> {
  late double _minRating;
  late int _maxDistanceKm;
  String? _selectedSpecialty;
  late bool _openNowOnly;

  @override
  void initState() {
    super.initState();
    final filter = ref.read(doctorFilterProvider);
    _minRating = filter.minRating.clamp(1.0, 5.0);
    _maxDistanceKm = filter.maxDistanceKm;
    _selectedSpecialty = filter.specialty;
    _openNowOnly = filter.openNowOnly;
  }

  void _resetFilters() {
    setState(() {
      _minRating = 1.0;
      _maxDistanceKm = 50;
      _selectedSpecialty = null;
      _openNowOnly = false;
    });
    ref.read(doctorFilterProvider.notifier).reset();
    Navigator.of(context).pop();
  }

  void _applyFilters() {
    final updatedFilter = DoctorFilter(
      minRating: _minRating == 1.0 ? 0.0 : _minRating,
      maxDistanceKm: _maxDistanceKm,
      specialty: _selectedSpecialty,
      openNowOnly: _openNowOnly,
    );
    ref.read(doctorFilterProvider.notifier).setFilter(updatedFilter);
    Navigator.of(context).pop();
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.filter_list,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: DesignTokens.sm + DesignTokens.xs),
                    Text(
                      'Filter Doctors',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: _resetFilters,
                  child: Text(
                    'Reset',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: DesignTokens.md),

            // Minimum Rating Slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Minimum Rating',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      color: AppColors.warning,
                      size: 18,
                    ),
                    const SizedBox(width: DesignTokens.xs),
                    Text(
                      '${_minRating.toStringAsFixed(1)}+ Stars',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                    ),
                  ],
                ),
              ],
            ),
            Slider(
              value: _minRating,
              min: 1.0,
              max: 5.0,
              divisions: 8,
              activeColor: AppColors.primary,
              inactiveColor: AppColors.divider,
              label: '${_minRating.toStringAsFixed(1)} ★',
              onChanged: (val) {
                setState(() => _minRating = val);
              },
            ),
            const SizedBox(height: DesignTokens.md),

            // Maximum Distance Slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Maximum Distance',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                ),
                Text(
                  'Within $_maxDistanceKm km',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                ),
              ],
            ),
            Slider(
              value: _maxDistanceKm.toDouble(),
              min: 1.0,
              max: 50.0,
              divisions: 49,
              activeColor: AppColors.primary,
              inactiveColor: AppColors.divider,
              label: '$_maxDistanceKm km',
              onChanged: (val) {
                setState(() => _maxDistanceKm = val.round());
              },
            ),
            const SizedBox(height: DesignTokens.md),

            // Specialty Dropdown
            Text(
              'Specialty',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: DesignTokens.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.sm + DesignTokens.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String?>(
                  value: _selectedSpecialty,
                  isExpanded: true,
                  hint: Text(
                    'All Specialties',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.primary,
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('All Specialties'),
                    ),
                    ...Specialty.values.map((s) {
                      return DropdownMenuItem<String?>(
                        value: s.label,
                        child: Text(s.label),
                      );
                    }),
                  ],
                  onChanged: (val) {
                    setState(() => _selectedSpecialty = val);
                  },
                ),
              ),
            ),
            const SizedBox(height: DesignTokens.md),

            // Open Now Only Switch
            Material(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
              child: SwitchListTile(
                value: _openNowOnly,
                activeThumbColor: AppColors.primary,
                title: Text(
                  'Open Now Only',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                ),
                subtitle: Text(
                  'Only show doctors currently open for appointments',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                onChanged: (val) {
                  setState(() => _openNowOnly = val);
                },
              ),
            ),
            const SizedBox(height: DesignTokens.lg),

            // Apply Filters Button
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
                  ),
                  textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                child: const Text('Apply Filters'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
