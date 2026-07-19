import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Get current GPS location
  static Future<Position?> getCurrentLocation() async {
    // Check if location service is enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return null;
    }

    // Check current permission
    LocationPermission permission = await Geolocator.checkPermission();

    // Request permission if denied
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // If still denied, return null
    if (permission == LocationPermission.denied) {
      return null;
    }

    // If permanently denied
    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    // Get current location (with timeout to avoid hanging/ANR
    // if no GPS fix is available, e.g. on an emulator with no
    // simulated location set)
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
      ),
    ).timeout(const Duration(seconds: 15));

    return position;
  }
}
