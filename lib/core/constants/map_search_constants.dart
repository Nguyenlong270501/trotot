/// Shared thresholds for map region property search.
abstract final class MapSearchConstants {
  static const double minZoomToSearch = 13;

  /// ~450m — skip Firestore when visible bounds barely moved after idle.
  static const double minBoundsLatDelta = 0.004;
  static const double minBoundsLngDelta = 0.004;

  /// Search again after panning this fraction of the visible viewport.
  static const double boundsSearchViewportFraction = 0.25;

  static const Duration regionSearchDebounce = Duration(milliseconds: 700);

  /// Firestore fetch pool for latitude-range queries; longitude is filtered client-side.
  static const int mapPropertyFetchLimit = 500;

  /// Maximum number of property pins rendered on the map at once.
  static const int mapPropertyRenderLimit = 50;

  static const Duration selectionCameraDuration = Duration(milliseconds: 400);
}
