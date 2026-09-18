import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Immutable model representing doctor search filter criteria.
@immutable
class DoctorFilter {
  /// Creates a [DoctorFilter] instance.
  const DoctorFilter({
    this.minRating = 0.0,
    this.maxDistanceKm = 50,
    this.specialty,
    this.district,
    this.openNowOnly = false,
  });

  /// Minimum doctor rating threshold (0.0 to 5.0).
  final double minRating;

  /// Maximum distance radius in kilometers (1 to 50 km).
  final int maxDistanceKm;

  /// Optional doctor specialty filter.
  final String? specialty;

  /// Optional district filter.
  final String? district;

  /// Filter doctors that are currently open.
  final bool openNowOnly;

  /// Returns true if default filter settings are active.
  bool get isDefault =>
      minRating <= 0.0 &&
      maxDistanceKm >= 50 &&
      specialty == null &&
      district == null &&
      !openNowOnly;

  /// Creates a copy of [DoctorFilter] with modified parameters.
  DoctorFilter copyWith({
    double? minRating,
    int? maxDistanceKm,
    String? specialty,
    bool clearSpecialty = false,
    String? district,
    bool clearDistrict = false,
    bool? openNowOnly,
  }) {
    return DoctorFilter(
      minRating: minRating ?? this.minRating,
      maxDistanceKm: maxDistanceKm ?? this.maxDistanceKm,
      specialty: clearSpecialty ? null : (specialty ?? this.specialty),
      district: clearDistrict ? null : (district ?? this.district),
      openNowOnly: openNowOnly ?? this.openNowOnly,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DoctorFilter &&
          runtimeType == other.runtimeType &&
          minRating == other.minRating &&
          maxDistanceKm == other.maxDistanceKm &&
          specialty == other.specialty &&
          district == other.district &&
          openNowOnly == other.openNowOnly;

  @override
  int get hashCode =>
      minRating.hashCode ^
      maxDistanceKm.hashCode ^
      specialty.hashCode ^
      district.hashCode ^
      openNowOnly.hashCode;

  @override
  String toString() =>
      'DoctorFilter(minRating: $minRating, maxDistanceKm: $maxDistanceKm, specialty: $specialty, district: $district, openNowOnly: $openNowOnly)';
}

/// Notifier managing [DoctorFilter] state.
class DoctorFilterNotifier extends Notifier<DoctorFilter> {
  @override
  DoctorFilter build() {
    return const DoctorFilter();
  }

  /// Sets the minimum rating filter value.
  void setMinRating(double rating) {
    state = state.copyWith(minRating: rating);
  }

  /// Sets the maximum distance radius in kilometers.
  void setMaxDistanceKm(int distanceKm) {
    state = state.copyWith(maxDistanceKm: distanceKm);
  }

  /// Sets or clears the specialty filter.
  void setSpecialty(String? specialty) {
    state = state.copyWith(
      specialty: specialty,
      clearSpecialty: specialty == null,
    );
  }

  /// Sets or clears the district filter.
  void setDistrict(String? district) {
    state = state.copyWith(
      district: district,
      clearDistrict: district == null,
    );
  }

  /// Sets whether to filter by doctors currently open.
  void setOpenNowOnly(bool openNowOnly) {
    state = state.copyWith(openNowOnly: openNowOnly);
  }

  /// Overwrites current filter state with [filter].
  void setFilter(DoctorFilter filter) {
    state = filter;
  }

  /// Resets filter criteria back to default values.
  void reset() {
    state = const DoctorFilter();
  }
}

/// Provider for managing [DoctorFilter] state.
final doctorFilterProvider =
    NotifierProvider<DoctorFilterNotifier, DoctorFilter>(
  DoctorFilterNotifier.new,
);
