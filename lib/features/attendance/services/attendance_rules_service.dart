import '../../../core/helpers/company_clock.dart';
import '../../../core/helpers/location_helper.dart';
import '../../dashboard/models/office_model.dart';
import '../models/attendance_action.dart';
import '../models/attendance_location_model.dart';
import '../models/attendance_record_model.dart';
import '../states/attendance_state.dart';

class AttendanceRuleException implements Exception {
  const AttendanceRuleException(this.feedback);
  final AttendanceFeedback feedback;
}

class AttendanceRulesService {
  // Enforces one same-day session and check-in before check-out.
  void validateAction(AttendanceAction action, AttendanceRecordModel? record) {
    if (action == AttendanceAction.checkIn && record != null) {
      throw AttendanceRuleException(
        record.checkOut == null
            ? AttendanceFeedback.alreadyCheckedIn
            : AttendanceFeedback.alreadyCheckedOut,
      );
    }
    if (action == AttendanceAction.checkOut && record == null) {
      throw const AttendanceRuleException(AttendanceFeedback.checkInRequired);
    }
    if (action == AttendanceAction.checkOut && record?.checkOut != null) {
      throw const AttendanceRuleException(AttendanceFeedback.alreadyCheckedOut);
    }
  }

  // Validates current location evidence against the configured office radius.
  void validateLocation(
    AttendanceLocationModel location,
    OfficeModel office,
    DateTime now,
  ) {
    if (!location.latitude.isFinite ||
        !location.longitude.isFinite ||
        location.latitude.abs() > 90 ||
        location.longitude.abs() > 180 ||
        !location.accuracy.isFinite ||
        location.accuracy < 0 ||
        now.difference(location.capturedAt).inSeconds > 120 ||
        location.capturedAt.difference(now).inSeconds > 30) {
      throw const AttendanceRuleException(
        AttendanceFeedback.locationUnavailable,
      );
    }
    if (LocationHelper.distance(
          location.latitude,
          location.longitude,
          office.latitude,
          office.longitude,
        ) >
        office.radiusMetres) {
      throw const AttendanceRuleException(AttendanceFeedback.outsideOffice);
    }
  }

  // Rejects an action if GPS acquisition crosses a company-date boundary.
  void validateDay(String date, DateTime now, String timezone) {
    if (CompanyClock.dateKey(now, timezone) != date) {
      throw const AttendanceRuleException(AttendanceFeedback.dayChanged);
    }
  }
}
