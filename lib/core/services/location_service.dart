import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  LatLng? _cachedLocation;
  LocationPermission _permission = LocationPermission.denied;

  bool get hasPermission =>
      _permission == LocationPermission.always ||
      _permission == LocationPermission.whileInUse;

  /// Sync cached permission from the OS without showing a dialog.
  Future<void> refreshPermissionStatus() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _permission = LocationPermission.denied;
      return;
    }
    _permission = await Geolocator.checkPermission();
  }

  /// Prompt for location when appropriate (e.g. after login).
  Future<bool> ensurePermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _permission = LocationPermission.denied;
      return false;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    _permission = permission;
    if (hasPermission) {
      await _refreshLocation();
    }
    return hasPermission;
  }

  /// @deprecated Prefer [ensurePermission] after login; kept for SOS call sites.
  Future<void> init() => ensurePermission().then((_) {});

  Future<LatLng?> getCurrentLocation() async {
    await refreshPermissionStatus();
    if (!hasPermission) return null;
    return _cachedLocation ?? _refreshLocation();
  }

  Future<LatLng?> _refreshLocation() async {
    if (!hasPermission) return null;

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      _cachedLocation = LatLng(position.latitude, position.longitude);
      return _cachedLocation;
    } catch (_) {
      return null;
    }
  }
}
