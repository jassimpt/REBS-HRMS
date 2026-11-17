import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as data;
import 'package:timezone/timezone.dart' as tz;

import '../constants/text_constants.dart';

abstract final class CompanyClock {
  static final _locations = _initialize();

  // Loads timezone data once for company date calculations.
  static Map<String, tz.Location> _initialize() {
    data.initializeTimeZones();
    return tz.timeZoneDatabase.locations;
  }

  // Converts an instant into the configured company timezone.
  static tz.TZDateTime inZone(DateTime instant, String timezone) {
    final location = _locations[timezone];
    if (location == null) {
      throw const FormatException('Invalid company timezone');
    }
    return tz.TZDateTime.from(instant.toUtc(), location);
  }

  // Returns a stable company calendar date for attendance comparisons.
  static String dateKey(DateTime instant, String timezone) {
    return DateFormat('yyyy-MM-dd').format(inZone(instant, timezone));
  }

  // Formats a timestamp in company time using a consistent 12-hour clock.
  static String time(DateTime? instant, String timezone) {
    if (instant == null) return TextConstants.notRecorded;
    return DateFormat('h:mm a').format(inZone(instant, timezone));
  }

  // Formats an attendance calendar date without applying device timezone.
  static String date(String date) {
    return DateFormat('EEE, dd MMM').format(DateTime.parse(date));
  }

  // Formats non-negative working time as hours and minutes.
  static String duration(Duration duration) {
    final minutes = duration.inMinutes.clamp(0, 24 * 60);
    return TextConstants.hoursAndMinutes(minutes ~/ 60, minutes % 60);
  }
}
