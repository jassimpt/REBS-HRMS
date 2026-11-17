abstract final class TextConstants {
  static const appName = 'REBS HRMS';
  static const brandName = 'REBS';
  static const workspace = 'Employee workspace';
  static const overview = 'Overview';
  static const attendance = 'Attendance';
  static const leave = 'Leave';
  static const applyForLeave = 'Apply for leave';
  static const leaveType = 'Leave type';
  static const startDate = 'Start date';
  static const endDate = 'End date';
  static const leaveReason = 'Reason';
  static const leaveReasonHint = 'Tell us why you need time away';
  static const leaveReasonHelp = 'At least 10 non-whitespace characters.';
  static const selectDate = 'Select date';
  static const calendarDaysNotice =
      'All calendar days count, including weekends and holidays.';
  static const submitLeave = 'Submit request';
  static const submittingLeave = 'Submitting your request…';
  static const leaveRequests = 'Your requests';
  static const leaveHistorySubtitle =
      'Track your leave applications and their status.';
  static const noLeaveTitle = 'No leave requests yet';
  static const noLeaveDescription =
      'Your submitted leave requests will appear here.';
  static const loadingLeave = 'Loading leave requests';
  static const leaveLoadErrorTitle = 'Leave information is unavailable';
  static const leaveOfflineCached =
      'Unable to reach the server. Your saved leave requests are available below. Submission requires a connection.';
  static const leaveOfflineNoCache =
      'Connect to the server to load leave information. Submission requires a connection.';
  static const leaveServerError =
      'The server could not load leave information. Please try again.';
  static const leaveInvalidResponse =
      'The leave response could not be verified. Please try again.';
  static const leaveCacheError =
      'Your leave information is current, but could not be saved for offline viewing.';
  static const leaveNeedsEmployee =
      'Refresh employee details before applying for leave.';
  static const leaveSubmitted = 'Your leave request has been submitted.';
  static const leaveSubmitOffline =
      'Leave submission requires a connection to the server. Your form has been kept so you can try again.';
  static const leaveSubmitTimeout =
      'The server did not respond in time. Refresh your requests or retry this unchanged form to check its outcome safely.';
  static const leaveSubmitRejected =
      'The server could not accept this request. Review the form and try again.';
  static const leaveSubmitServerError =
      'The server is unavailable. Your form has been kept so you can try again.';
  static const pending = 'Pending';
  static const approved = 'Approved';

  // Provides field validation text without embedding labels in form widgets.
  static String? leaveValidation(String? issue) => switch (issue) {
    'required' => 'Choose a date.',
    'invalidDate' => 'Choose a valid date.',
    'startInPast' => 'Start date cannot be before the current company date.',
    'endBeforeStart' => 'End date cannot be before the start date.',
    'reasonTooShort' => 'Enter at least 10 non-whitespace characters.',
    'balanceExceeded' =>
      'Requested days exceed the available balance for this leave type.',
    'overlapping' => 'These dates overlap a Pending or Approved leave request.',
    _ => null,
  };

  // Formats the requested duration using inclusive calendar days.
  static String leaveDays(int days) =>
      '$days calendar ${days == 1 ? 'day' : 'days'}';

  // Labels a request with its supported leave type.
  static String leaveRequestTitle(String type) =>
      '${type == 'casual' ? casual : sick} leave';

  // Formats the start and end calendar dates of a leave request.
  static String leaveDateRange(String start, String end) => '$start – $end';
  static const overviewSubtitle = 'A clear view of your working day.';
  static const attendanceSubtitle = 'Keep track of your time at work.';
  static const leaveSubtitle = 'Make room for your time away.';
  static const refresh = 'Refresh';
  static const retry = 'Try again';
  static const loadingDashboard = 'Loading your workspace';
  static const dashboardErrorTitle = 'Your workspace is unavailable';
  static const offlineMessage =
      'Unable to reach the server. Check your connection and try again.';
  static const offlineCachedMessage =
      'Unable to reach the server. Showing your saved information.';
  static const timeoutMessage =
      'The server is taking too long. Please try again.';
  static const serverErrorMessage =
      'The server could not load your workspace. Please try again.';
  static const invalidResponseMessage =
      'We could not read the workspace information. Please try again.';
  static const cacheErrorMessage =
      'Your information is up to date, but could not be saved for offline use.';
  static const savedDataMessage = 'Showing saved information.';
  static const refreshing = 'Updating your workspace…';
  static const todayAttendance = 'Today’s attendance';
  static const notCheckedIn = 'Not Checked In';
  static const checkedIn = 'Checked In';
  static const checkedOut = 'Checked Out';
  static const checkIn = 'Check-in';
  static const checkOut = 'Check-out';
  static const workingTime = 'Working time';
  static const notRecorded = '—';
  static const leaveBalance = 'Available leave';
  static const daysAvailable = 'days available';
  static const casual = 'Casual';
  static const sick = 'Sick';
  static const recentAttendance = 'Recent attendance';
  static const latestFiveRecords = 'Your latest five attendance records';
  static const noAttendanceTitle = 'No attendance yet';
  static const noAttendanceDescription =
      'Your attendance records will appear here after your first check-in.';
  static const synced = 'Synced';
  static const inProgress = 'In progress';
  static const companyTime = 'Company time';
  static const pendingSync = 'Pending Sync';
  static const attendanceSync = 'Attendance sync';
  static const syncNow = 'Sync Now';
  static const syncRestoring = 'Checking saved attendance…';
  static const syncInProgress = 'Synchronizing attendance…';
  static const syncUpToDate = 'No attendance actions are waiting to sync.';
  static const syncOffline =
      'You are offline. Saved actions will sync when you reconnect.';
  static const syncServerUnavailable =
      'The server is unavailable. Your actions are saved and will retry automatically.';
  static const syncTimedOut =
      'The server did not respond in time. Your actions are saved and will retry safely.';
  static const syncInvalidResponse =
      'The server response could not be verified. Your actions remain saved for retry.';
  static const syncStorageError =
      'We could not access saved attendance. Please try again.';
  static const syncRejected =
      'Some actions were rejected. Review them in Attendance activity.';
  static const syncPending = 'Saved actions are waiting to synchronize.';

  // Labels the number of actions still waiting for acknowledgement.
  static String pendingActions(int count) => '$count pending';

  // Labels rejected actions that require review rather than automatic retry.
  static String rejectedActions(int count) => '$count rejected';
  static const rejected = 'Rejected';
  static const checkInSuccess = 'Checked in successfully.';
  static const checkOutSuccess = 'Checked out successfully.';
  static const attendanceSavedPending =
      'Saved on this device. Your attendance is pending synchronization.';
  static const attendanceRejected =
      'The server rejected this action. Your attendance has been refreshed.';
  static const attendanceStorageError =
      'We could not save your attendance safely. Please try again.';
  static const locationDenied =
      'Location permission is needed to record attendance. Please allow access and try again.';
  static const locationPermanentlyDenied =
      'Location permission is blocked. Enable it in app settings and try again.';
  static const locationDisabled =
      'Location services are turned off. Enable them and try again.';
  static const locationUnavailable =
      'We could not get a current location. Move to an area with a better GPS signal and try again.';
  static const outsideOffice =
      'You are outside the permitted office area. Move within the office attendance radius and try again.';
  static const checkInRequired = 'Check in before checking out.';
  static const alreadyCheckedIn = 'You have already checked in today.';
  static const alreadyCheckedOut =
      'You have already completed attendance for today.';
  static const attendanceDayChanged =
      'The company date changed while checking your location. Please try again.';
  static const openAppSettings = 'Open app settings';
  static const openLocationSettings = 'Open location settings';
  static const recordingAttendance =
      'Checking your location and recording attendance…';
  static const attendanceComplete = 'Your attendance is complete for today.';
  static const attendanceActivity = 'Attendance activity';

  // Explains where attendance may be recorded.
  static String officeRadius(int metres) =>
      'Check in and out within $metres metres of this office. Your current GPS location is captured for each action.';

  // Formats captured coordinates for reviewing an attendance action.
  static String coordinates(double latitude, double longitude) =>
      'Location · ${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}';

  // Maps server rejection codes to clear attendance messages.
  static String attendanceRejectionReason(String? code) => switch (code) {
    'attendance_exists' =>
      'Attendance already exists for this session or company date.',
    'check_in_required' => checkInRequired,
    'check_in_rejected' =>
      'This checkout could not be submitted because its check-in was rejected.',
    'invalid_location' => 'The server could not validate this location.',
    'idempotency_mismatch' =>
      'This event ID was already used for a different action.',
    _ => 'The server could not accept this attendance action.',
  };

  // Formats a working duration with consistent unit labels.
  static String hoursAndMinutes(int hours, int minutes) =>
      '${hours}h ${minutes}m';

  // Identifies the employee without embedding labels in widgets.
  static String employeeId(String id) => 'Employee ID · $id';

  // Shows when the current dashboard snapshot was last saved.
  static String lastUpdated(String time) => 'Last updated $time';

  // Labels the company timezone used for attendance dates.
  static String timezone(String timezone) => '$companyTime · $timezone';
}
