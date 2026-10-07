import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:geolocator/geolocator.dart';

import '../models/location_point.dart';

abstract class LocationService {
  Future<LocationPermissionStatus> checkPermission();
  Future<LocationRequestResult> requestCurrentLocation();
  Future<bool> isNetworkAvailable();
}

enum LocationPermissionStatus {
  granted,
  denied,
  permanentlyDenied,
  serviceDisabled,
}

class DeviceLocationService implements LocationService {
  @override
  Future<LocationPermissionStatus> checkPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationPermissionStatus.serviceDisabled;
    }

    final permission = await Geolocator.checkPermission();
    switch (permission) {
      case LocationPermission.always:
      case LocationPermission.whileInUse:
        return LocationPermissionStatus.granted;
      case LocationPermission.denied:
        return LocationPermissionStatus.denied;
      case LocationPermission.deniedForever:
        return LocationPermissionStatus.permanentlyDenied;
      case LocationPermission.unableToDetermine:
        return LocationPermissionStatus.denied;
    }
  }

  @override
  Future<LocationRequestResult> requestCurrentLocation() async {
    try {
      final permissionStatus = await checkPermission();
      if (permissionStatus == LocationPermissionStatus.serviceDisabled) {
        return LocationRequestResult.failure(
          'Location services are disabled on this device.',
        );
      }

      if (permissionStatus == LocationPermissionStatus.denied) {
        final requested = await Geolocator.requestPermission();
        if (requested == LocationPermission.denied) {
          return LocationRequestResult.failure(
            'Location permission was denied. Please allow access to submit your status.',
          );
        }
        if (requested == LocationPermission.deniedForever) {
          return LocationRequestResult.failure(
            'Location access is permanently denied. Please enable it in Settings.',
          );
        }
      }

      if (permissionStatus == LocationPermissionStatus.permanentlyDenied) {
        return LocationRequestResult.failure(
          'Location access is permanently denied. Please enable it in Settings.',
        );
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      return LocationRequestResult.success(
        LocationPoint(
          latitude: position.latitude,
          longitude: position.longitude,
          timestamp: DateTime.now(),
        ),
      );
    } on TimeoutException {
      return LocationRequestResult.failure(
        'Location could not be obtained in time. Please try again.',
      );
    } on LocationServiceDisabledException {
      return LocationRequestResult.failure(
        'Location services are disabled. Enable them and try again.',
      );
    } on PermissionDeniedException {
      return LocationRequestResult.failure(
        'Location permission was denied. Please allow access to submit your status.',
      );
    } on Exception {
      return LocationRequestResult.failure(
        'Location is unavailable right now. Please try again shortly.',
      );
    }
  }

  @override
  Future<bool> isNetworkAvailable() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return !connectivityResult.contains(ConnectivityResult.none);
  }
}
