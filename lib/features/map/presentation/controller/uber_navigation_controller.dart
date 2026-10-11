import 'dart:async';
import 'package:flutter_task/core/services/location_socket_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class UberNavigationController extends GetxController {
  final LocationSocketService _socketService = LocationSocketService();

  final currentPosition = Rxn<Position>();
  final currentHeading = 0.0.obs;
  final isNavigating = false.obs;

  StreamSubscription<Position>? _positionStreamSub;
  GoogleMapController? mapController;

  // 1-second GPS stream settings
  final LocationSettings _locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 2, // 2 meters threshold for high accuracy movement
  );

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void startUberNavigationStream() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    isNavigating.value = true;
    _positionStreamSub?.cancel();

    _positionStreamSub = Geolocator.getPositionStream(
      locationSettings: _locationSettings,
    ).listen((Position position) {
      currentPosition.value = position;
      currentHeading.value = position.heading >= 0 ? position.heading : currentHeading.value;

      // 1. Emit live location over Socket.IO (1 sec cadence)
      _socketService.pingLocation(
        lat: position.latitude,
        lon: position.longitude,
        speed: position.speed >= 0 ? position.speed * 2.23694 : null, // Convert m/s to mph
        heading: position.heading >= 0 ? position.heading : null,
        deviceTs: position.timestamp,
      );

      // 2. Smooth camera animation (500-800ms) with bearing follow like Uber
      if (mapController != null && isNavigating.value) {
        mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 17.5,
              bearing: position.heading >= 0 ? position.heading : 0.0,
              tilt: 45.0, // 3D driving perspective
            ),
          ),
        );
      }
    });
  }

  void stopUberNavigationStream() {
    isNavigating.value = false;
    _positionStreamSub?.cancel();
    _positionStreamSub = null;
  }

  @override
  void onClose() {
    stopUberNavigationStream();
    super.onClose();
  }
}
