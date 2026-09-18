/// Application feature flags governing V1 launch scope.
abstract final class AppFeatures {
  /// Whether appointment booking and the Appointments tab are enabled.
  ///
  /// In Disha V1, patient interaction is centered on discovery, direct calling,
  /// WhatsApp, and clinic visits. Set to false to hide the Appointments shell tab
  /// and /booking route. All underlying booking code, models, and repositories
  /// remain preserved for V2.
  static const bool showBooking = false;
}
