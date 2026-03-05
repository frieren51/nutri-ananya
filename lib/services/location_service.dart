import 'package:geolocator/geolocator.dart';
import 'dart:async';

class LocationService {
  Future<Position> getCurrentLocation() async {
    // 1. Check if GPS service is enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // You might want to suggest opening settings here
      return Future.error("Location services are disabled.");
    }

    // 2. Check current permission status
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      // Request permission for the first time
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        // User denied the permission popup
        return Future.error("Location permissions are denied.");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
        "Location permissions are permanently denied. Please enable them in settings.",
      );
    }

    // 3. Get the actual position with a timeout
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15), // Prevent infinite loading
      );
    } on TimeoutException catch (_) {
      return Future.error("Location request timed out. Are you indoors?");
    } catch (e) {
      return Future.error("An error occurred: $e");
    }
  }
}
