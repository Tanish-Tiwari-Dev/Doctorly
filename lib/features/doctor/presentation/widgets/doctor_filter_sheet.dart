import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:doctorly/features/doctor/presentation/providers/doctor_filter_provider.dart';
import 'package:doctorly/utils/design_tokens.dart';

/// Modal bottom sheet widget for setting doctor search filters (Rating, Distance, District).
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
  String? _selectedDistrict;
  late bool _openNowOnly;

  static const List<String> _districts = [
    'Ahmedabad',
    'Amreli',
    'Anand',
    'Aravalli',
    'Banaskantha',
    'Bharuch',
    'Bhavnagar',
    'Botad',
    'Chhota Udaipur',
    'Dahod',
    'Dang',
    'Devbhoomi Dwarka',
    'Gandhinagar',
    'Gir Somnath',
    'Jamnagar',
    'Junagadh',
    'Kheda',
    'Kutch',
    'Mahisagar',
    'Mehsana',
    'Morbi',
    'Narmada',
    'Navsari',
    'Panchmahal',
    'Patan',
    'Porbandar',
    'Rajkot',
    'Sabarkantha',
    'Surat',
    'Surendranagar',
    'Tapi',
    'Vadodara',
    'Valsad',
    'Central Delhi',
    'East Delhi',
    'New Delhi',
    'North Delhi',
    'North East Delhi',
    'North West Delhi',
    'Shahdara',
    'South Delhi',
    'South East Delhi',
    'South West Delhi',
    'West Delhi',
  ];

  @override
  void initState() {
    super.initState();
    final filter = ref.read(doctorFilterProvider);
    _minRating = filter.minRating.clamp(1.0, 5.0);
    _maxDistanceKm = filter.maxDistanceKm;
    _selectedDistrict = filter.district;
    _openNowOnly = filter.openNowOnly;
  }

  void _resetFilters() {
    setState(() {
      _minRating = 1.0;
      _maxDistanceKm = 50;
      _selectedDistrict = null;
      _openNowOnly = false;
    });
    ref.read(doctorFilterProvider.notifier).reset();
    Navigator.of(context).pop();
  }

  void _applyFilters() {
    final updatedFilter = DoctorFilter(
      minRating: _minRating == 1.0 ? 0.0 : _minRating,
      maxDistanceKm: _maxDistanceKm,
      district: _selectedDistrict,
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
                  color: DesignTokens.divider,
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
                      color: DesignTokens.primary,
                      size: 24,
                    ),
                    const SizedBox(width: DesignTokens.sm + DesignTokens.xs),
                    Text(
                      'Filter Doctors',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: DesignTokens.textPrimary,
                          ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: _resetFilters,
                  child: Text(
                    'Reset',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: DesignTokens.error,
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
                        color: DesignTokens.textPrimary,
                      ),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      color: DesignTokens.starRating,
                      size: 18,
                    ),
                    const SizedBox(width: DesignTokens.xs),
                    Text(
                      '${_minRating.toStringAsFixed(1)}+ Stars',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: DesignTokens.textPrimary,
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
              activeColor: DesignTokens.primary,
              inactiveColor: DesignTokens.divider,
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
                        color: DesignTokens.textPrimary,
                      ),
                ),
                Text(
                  'Within $_maxDistanceKm km',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: DesignTokens.textPrimary,
                      ),
                ),
              ],
            ),
            Slider(
              value: _maxDistanceKm.toDouble(),
              min: 1.0,
              max: 50.0,
              divisions: 49,
              activeColor: DesignTokens.primary,
              inactiveColor: DesignTokens.divider,
              label: '$_maxDistanceKm km',
              onChanged: (val) {
                setState(() => _maxDistanceKm = val.round());
              },
            ),
            const SizedBox(height: DesignTokens.md),

            // District Filter Dropdown
            Text(
              'District',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: DesignTokens.textPrimary,
                  ),
            ),
            const SizedBox(height: DesignTokens.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.sm + DesignTokens.xs,
              ),
              decoration: BoxDecoration(
                color: DesignTokens.inputBackground,
                borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String?>(
                  value: _selectedDistrict,
                  isExpanded: true,
                  hint: Text(
                    'All Districts',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: DesignTokens.textSecondary,
                        ),
                  ),
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: DesignTokens.primary,
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('All Districts'),
                    ),
                    ..._districts.map((d) {
                      return DropdownMenuItem<String?>(
                        value: d,
                        child: Text(d),
                      );
                    }),
                  ],
                  onChanged: (val) {
                    setState(() => _selectedDistrict = val);
                  },
                ),
              ),
            ),
            const SizedBox(height: DesignTokens.md),

            // Open Now Switch
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.sm + DesignTokens.xs,
                vertical: DesignTokens.xs,
              ),
              decoration: BoxDecoration(
                color: DesignTokens.inputBackground,
                borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        color: DesignTokens.primary,
                        size: 20,
                      ),
                      const SizedBox(width: DesignTokens.sm),
                      Text(
                        'Open Now Only',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: DesignTokens.textPrimary,
                            ),
                      ),
                    ],
                  ),
                  Switch.adaptive(
                    value: _openNowOnly,
                    activeTrackColor: DesignTokens.primary,
                    onChanged: (val) {
                      setState(() => _openNowOnly = val);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: DesignTokens.lg),

            // Apply Button
            ElevatedButton(
              onPressed: _applyFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignTokens.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: DesignTokens.sm + DesignTokens.xs,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
                ),
              ),
              child: Text(
                'Apply Filters',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
