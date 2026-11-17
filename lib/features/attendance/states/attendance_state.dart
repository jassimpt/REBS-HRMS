import '../models/attendance_event_model.dart';

enum AttendanceFeedback {
  checkedIn,
  checkedOut,
  savedPending,
  rejected,
  storageError,
  locationDenied,
  locationPermanentlyDenied,
  locationDisabled,
  locationUnavailable,
  outsideOffice,
  checkInRequired,
  alreadyCheckedIn,
  alreadyCheckedOut,
  dayChanged,
}

class AttendanceState {
  const AttendanceState({
    this.events = const [],
    this.isLoading = true,
    this.isSubmitting = false,
    this.feedback,
  });

  final List<AttendanceEventModel> events;
  final bool isLoading;
  final bool isSubmitting;
  final AttendanceFeedback? feedback;
}
