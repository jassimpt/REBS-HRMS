import 'dart:math' as math;

abstract final class LocationHelper {
  // Measures great-circle distance in metres between two GPS coordinates.
  static double distance(
    double latitude,
    double longitude,
    double officeLatitude,
    double officeLongitude,
  ) {
    const radians = math.pi / 180;
    final latitudeDifference = (officeLatitude - latitude) * radians;
    final longitudeDifference = (officeLongitude - longitude) * radians;
    final value =
        math.pow(math.sin(latitudeDifference / 2), 2) +
        math.cos(latitude * radians) *
            math.cos(officeLatitude * radians) *
            math.pow(math.sin(longitudeDifference / 2), 2);
    return 6371000 * 2 * math.asin(math.sqrt(value.clamp(0, 1)));
  }
}
