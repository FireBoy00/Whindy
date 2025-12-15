import 'package:flutter/services.dart';
import 'dart:io' show Platform;

/// Service that demonstrates Flutter Platform Channels
/// This communicates with native Android/iOS code to get GPS location
class LocationService {
  // Create a MethodChannel with a unique identifier
  static const platform = MethodChannel('com.whindy.location');

  /// Gets the current GPS location from the native platform
  /// Returns a Map with 'latitude' and 'longitude' keys
  /// Returns null if running on web or if there's an error
  Future<Map<String, double>?> getCurrentLocation() async {
    // Platform channels don't work on web, so return null
    if (!_isPlatformSupported()) {
      print('Location service: Platform not supported (web)');
      return null;
    }

    try {
      print('Location service: Requesting location from native platform...');
      // Invoke the native method 'getCurrentLocation'
      // This will call the corresponding native code on Android/iOS
      final Map<dynamic, dynamic> result = await platform.invokeMethod(
        'getCurrentLocation',
      );

      print(
        'Location service: Received location - '
        'lat: ${result['latitude']}, lon: ${result['longitude']}',
      );

      return {
        'latitude': result['latitude'] as double,
        'longitude': result['longitude'] as double,
      };
    } on PlatformException catch (e) {
      print(
        "Location service: Platform exception - Code: ${e.code}, Message: '${e.message}'",
      );
      return null;
    } catch (e) {
      print("Location service: Unexpected error - $e");
      return null;
    }
  }

  /// Checks if the current platform supports platform channels
  bool _isPlatformSupported() {
    try {
      return Platform.isAndroid || Platform.isIOS;
    } catch (e) {
      // If Platform class throws (e.g., on web), return false
      return false;
    }
  }
}
