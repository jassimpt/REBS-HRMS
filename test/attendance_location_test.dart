import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rebs_hrms/features/attendance/services/attendance_location_service.dart';
import 'package:rebs_hrms/features/attendance/services/attendance_rules_service.dart';
import 'package:rebs_hrms/features/attendance/states/attendance_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('flutter.baseflow.com/geolocator');
  final service = AttendanceLocationService();
  var enabled = true;
  var permission = 2;
  var requestResult = 2;
  var gpsUnavailable = false;
  setUp(() {
    enabled = true;
    permission = 2;
    requestResult = 2;
    gpsUnavailable = false;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          return switch (call.method) {
            'isLocationServiceEnabled' => enabled,
            'checkPermission' => permission,
            'requestPermission' => requestResult,
            'getCurrentPosition' =>
              gpsUnavailable
                  ? throw PlatformException(code: 'LOCATION_UPDATE_FAILURE')
                  : {
                      'latitude': 12.9716,
                      'longitude': 77.5946,
                      'accuracy': 5.0,
                      'timestamp': DateTime.now().millisecondsSinceEpoch,
                    },
            _ => true,
          };
        });
  });
  tearDown(
    () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null),
  );

  test('Foreground permission captures GPS coordinates', () async {
    expect((await service.capture()).latitude, 12.9716);
  });
  test('Denied and permanently denied permissions are distinct', () async {
    permission = 0;
    requestResult = 0;
    await expectLater(
      service.capture(),
      throwsA(
        isA<AttendanceRuleException>().having(
          (error) => error.feedback,
          'reason',
          AttendanceFeedback.locationDenied,
        ),
      ),
    );
    permission = 1;
    await expectLater(
      service.capture(),
      throwsA(
        isA<AttendanceRuleException>().having(
          (error) => error.feedback,
          'reason',
          AttendanceFeedback.locationPermanentlyDenied,
        ),
      ),
    );
  });
  test('Disabled location and unavailable GPS are distinct', () async {
    enabled = false;
    await expectLater(
      service.capture(),
      throwsA(
        isA<AttendanceRuleException>().having(
          (error) => error.feedback,
          'reason',
          AttendanceFeedback.locationDisabled,
        ),
      ),
    );
    enabled = true;
    gpsUnavailable = true;
    await expectLater(
      service.capture(),
      throwsA(
        isA<AttendanceRuleException>().having(
          (error) => error.feedback,
          'reason',
          AttendanceFeedback.locationUnavailable,
        ),
      ),
    );
  });
}
