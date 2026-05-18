/// Shared thresholds for map region property search.
abstract final class MapSearchConstants {
  static const double minZoomToSearch = 13;

  /// ~450m — skip Firestore when visible bounds barely moved after idle.
  static const double minBoundsLatDelta = 0.004;
  static const double minBoundsLngDelta = 0.004;

  static const Duration regionSearchDebounce = Duration(milliseconds: 700);

  static const int mapPropertyQueryLimit = 50;

  static const Duration selectionCameraDuration = Duration(milliseconds: 400);
}
