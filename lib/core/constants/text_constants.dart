abstract final class TextConstants {
  static const appName = 'REBS HRMS';
  static const brandName = 'REBS';
  static const workspace = 'Employee workspace';
  static const overview = 'Overview';
  static const attendance = 'Attendance';
  static const leave = 'Leave';
  static const overviewSubtitle = 'A clear view of your working day.';
  static const attendanceSubtitle = 'Keep track of your time at work.';
  static const leaveSubtitle = 'Make room for your time away.';
  static const overviewTitle = 'Your workday at a glance';
  static const overviewDescription =
      'Your employee details, daily summary and recent attendance will appear here.';
  static const attendanceTitle = 'Your attendance, together';
  static const attendanceDescription =
      'Your check-in, check-out and attendance history will appear here.';
  static const leaveTitle = 'Plan your time away';
  static const leaveDescription =
      'Your leave balance and requests will appear here.';
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
