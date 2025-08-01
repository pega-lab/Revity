import 'package:geolocator/geolocator.dart';

/// A utility class to fetch the device's current location using the
/// `geolocator` package.
class LocationService {
  /// Requests permission (if necessary) and returns the current position.
  ///
  /// Throws a [PermissionDeniedException] if location permissions are denied,
  /// or an [Exception] if location services are disabled.
  static Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw PermissionDeniedException('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw PermissionDeniedException(
        'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }
}
