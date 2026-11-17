import 'package:geolocator/geolocator.dart';

import '../models/attendance_location_model.dart';
import '../states/attendance_state.dart';
import 'attendance_rules_service.dart';

class AttendanceLocationService {
  // Requests foreground location permission and acquires a fresh GPS position.
  Future<AttendanceLocationModel> capture() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw const AttendanceRuleException(
          AttendanceFeedback.locationDisabled,
        );
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        throw const AttendanceRuleException(
          AttendanceFeedback.locationPermanentlyDenied,
        );
      }
      if (permission != LocationPermission.always &&
          permission != LocationPermission.whileInUse) {
        throw const AttendanceRuleException(AttendanceFeedback.locationDenied);
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
      return AttendanceLocationModel(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        capturedAt: position.timestamp.toUtc(),
      );
    } on AttendanceRuleException {
      rethrow;
    } on LocationServiceDisabledException {
      throw const AttendanceRuleException(AttendanceFeedback.locationDisabled);
    } catch (_) {
      throw const AttendanceRuleException(
        AttendanceFeedback.locationUnavailable,
      );
    }
  }

  // Opens this app's permission settings after permanent denial.
  Future<bool> openAppSettings() => Geolocator.openAppSettings();

  // Opens device location settings when GPS services are disabled.
  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();
}
